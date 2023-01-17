# frozen_string_literal: true

require "hashdiff"
require_relative "local"
require_relative "remote"

module Moura
  module Model
    class Diff
      attr_reader :diff

      def initialize(local_file)
        @local = Local.new(local_file)
        @remote = Remote.new

        hash_diff = Hashdiff.diff(@remote.dump, @local.dump)
        @diff = parse_hash_diff(hash_diff)

        validate_diff_data
      end

      def parse_hash_diff(data)
        data.each_with_object({}) do |(mark, target, diff), result|
          (role_name, child) = target.match(/^(.+?)(?:\.(apps|users)(?:\[\d+\])?)?$/).captures
          action = mark == "+" ? :add : :remove

          unless result[role_name]
            result[role_name] = {
              action: :none,
              apps: { add: [], remove: [] },
              users: { add: [], remove: [] }
            }
          end

          if child
            result[role_name][child.to_sym][action] <<= diff
          else
            result[role_name][:action] = action
            result[role_name][:apps][action] += diff.fetch("apps", [])
            result[role_name][:users][action] += diff.fetch("users", [])
          end
        end
      end

      def validate_diff_data
        apps = @diff.map { |_, v| v[:apps][:add] }.flatten.sort.uniq
        @remote.validate_apps(apps)

        emails = @diff.map { |_, v| v[:users][:add] }.flatten.sort.uniq
        @remote.validate_emails(emails)
      end

      def apply
        @diff.each do |role, attr|
          case attr[:action]
          when :add
            @remote.create_role(role)
          when :remove
            @remote.delete_role(role)
            next
          end

          apps = attr[:apps]
          add_apps = apps[:add]
          remove_apps = apps[:remove]
          if add_apps.present? || remove_apps.present?
            merged_app_ids = merge_role_apps(role, apps[:add], apps[:remove])
            @remote.set_role_apps(role, merged_app_ids)
          end

          users = attr[:users]
          @remote.add_role_users(role, users[:add])
          @remote.remove_role_users(role, users[:remove])
        end
      end

      def merge_role_apps(role, add, remove)
        current_apps = @remote.role(role).apps
        add_apps = add.map { |name| @remote.find_app_id_by_name(name) }
        remove_apps = remove.map { |name| @remote.find_app_id_by_name(name) }
        current_apps + add_apps - remove_apps
      end
    end
  end
end

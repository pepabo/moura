# frozen_string_literal: true

require "hashdiff"
require_relative "local"
require_relative "remote"

module Moura
  module Model
    class Diff
      DiffData = Struct.new(:add, :remove, :add_role_users, :remove_role_users) do
        def initialize
          super([], [], {}, {})
        end

        def self.parse(diff_data)
          diff_data.each_with_object(new) do |(mark, role, diff), result|
            normalize_name = role.sub(/\[\d+\]$/, "")
            diff = [diff].flatten

            # [\d+]で終わっていたらユーザの変更のみ
            if role =~ /\[\d+\]/
              case mark
              when "+"
                result.add_role_users[normalize_name] = diff
              when "-"
                result.remove_role_users[normalize_name] = diff
              end
            else
              case mark
              when "+"
                result.add << normalize_name

                # diffが空じゃない場合ユーザも追加
                result.add_role_users[normalize_name] = diff unless diff.empty?
              when "-"
                result.remove << normalize_name
              end
            end
          end
        end

        def to_h
          result = add.to_h { |a| [a, { action: :add, users: {} }] }
          result.merge!(remove.to_h { |r| [r, { action: :remove, users: {} }] })

          [
            %i[add_role_users add],
            %i[remove_role_users remove]
          ].each do |method, action|
            send(method).each do |role, users|
              result[role] ||= { users: {} }
              result[role][:users][action] = users
            end
          end

          result.sort_by(&:first).to_h
        end
      end

      attr_reader :diff

      def initialize(local_file)
        @local = Local.new(local_file)
        roles_diff = Hashdiff.diff(Remote.role_users, @local.roles)

        @diff = DiffData.parse(roles_diff)
      end

      def apply
        @diff.add.each do |role|
          Remote.create_role(role, @diff.add_role_users[role])
        end

        @diff.add_role_users
             .except(*@diff.add) # すでにロールを追加していたら不要
             .each do |role, users|
          Remote.add_role_users(role, users)
        end

        @diff.remove.each do |role|
          Remote.delete_role(role)
        end

        @diff.remove_role_users
             .except(*@diff.remove) # すでにロールを削除していたら不要
             .each do |role, users|
          Remote.remove_role_users(role, users)
        end
      end
    end
  end
end

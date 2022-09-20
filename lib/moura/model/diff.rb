# frozen_string_literal: true

require "hashdiff"
require_relative "local"
require_relative "remote"

module Moura
  module Model
    class Diff
      DiffClass = Struct.new(:add, :remove, :add_user, :remove_user) do
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
                result.add_user[normalize_name] = diff
              when "-"
                result.remove_user[normalize_name] = diff
              end
            else
              case mark
              when "+"
                result.add << normalize_name

                # diffが空じゃない場合ユーザも追加
                result.add_user[normalize_name] = diff unless diff.empty?
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
            %i[add_user add],
            %i[remove_user remove]
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
        @remote = Remote.new
        roles_diff = Hashdiff.diff(@remote.roles, @local.roles)

        @diff = DiffClass.parse(roles_diff)
      end
    end
  end
end

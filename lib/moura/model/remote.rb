# frozen_string_literal: true

require "onelogin/api"
require "yaml"

module Moura
  module Model
    class Remote
      def self.client
        @client ||= client!
      end

      def self.client!
        OneLogin.configure do |config|
          config.host = "pepabo.onelogin.com"
          config.debugging = ENV.fetch("MOURA_DEBUG", false)
        end

        client_id = ENV.fetch("ONELOGIN_CLIENT_ID")
        client_secret = ENV.fetch("ONELOGIN_CLIENT_SECRET")
        OneLogin::Api.new(client_id, client_secret)
      end

      def self.dump
        puts YAML.dump(roles.sort_by(&:first).to_h)
      end

      def self.find_user_id_by_email(email)
        @users.values.find do |user|
          user.email == email
        end.id
      end

      def self.users
        @users ||= users!
      end

      def self.users!
        # データを圧縮するために取得フィールドを絞る
        client.list_users(fields: "id,email,firstname,lastname", limit: 1000).to_h do |user|
          [user.id, user]
        end
      end

      def self.find_role_id(name)
        role = roles[name]
        raise RoleNotFound unless role

        role.id
      end

      def self.roles
        @roles ||= roles!
      end

      def self.roles!
        client.list_roles(limit: 1000).sort_by(&:id).to_h do |role|
          [role.name, role]
        end
      end

      def self.role_users
        roles.to_h do |_name, role|
          emails = role.users.map do |id|
            users[id].email
          end
          [role.name, emails.sort]
        end
      end

      def self.create_role(role, users = nil)
        body = { name: role }

        user_ids = users&.map { |user| find_user_id_by_email(user) }
        body[:users] = user_ids if user_ids

        client.create_roles(debug_body: body)
      end

      def self.add_role_users(role, users)
        role_id = find_role_id(role)
        user_ids = users&.map { |user| find_user_id_by_email(user) }

        client.add_role_users(role_id, user_ids) if user_ids
      end

      def self.delete_role(role)
        role_id = find_role_id(role)
        client.delete_role(role_id)
      end

      def self.remove_role_users(role, users)
        role_id = find_role_id(role)
        user_ids = users&.map { |user| find_user_id_by_email(user) }

        client.remove_role_users(role_id, user_ids) if user_ids
      end
    end
  end
end

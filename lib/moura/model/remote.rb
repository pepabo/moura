# frozen_string_literal: true

require_relative "../onelogin"
require "onelogin/api"
require "yaml"

module Moura
  module Model
    class Remote
      def initialize
        @client = OneLogin.client

        # データを圧縮するために取得フィールドを絞る
        @users = @client.list_users(fields: "id,email,firstname,lastname", limit: 1000).to_h do |user|
          [user.id, user]
        end
        @apps = @client.list_apps(limit: 1000).to_h { |app| [app.id, app] }
        update_roles
      end

      def role(name)
        @roles[name]
      end

      def app(id)
        @apps[id]
      end

      def find_role_id(name)
        role = @roles[name]
        raise RoleNotFound unless role

        role.id
      end

      def dump
        @roles.map do |(name, role)|
          apps = role.apps.map { |id| @apps[id].name }.sort
          users = role.users.map { |id| @users[id].email }.sort
          [name, { "apps" => apps, "users" => users }]
        end.sort_by(&:first).to_h
      end

      def validate_apps(apps)
        apps.each do |app|
          raise ApplicationNotFound, app unless find_app_id_by_name(app)
        end
      end

      def validate_emails(emails)
        emails.each do |email|
          raise UserNotFound, email unless find_user_id_by_email(email)
        end
      end

      def create_role(name)
        body = { name: }
        @client.create_roles(debug_body: body)
        update_roles
      end

      def set_role_apps(name, app_ids)
        role_id = find_role_id_by_name(name)
        @client.set_role_apps(role_id, app_ids)
      end

      def add_role_users(name, emails)
        role_id = find_role_id_by_name(name)
        user_ids = emails&.map { |email| find_user_id_by_email(email) }

        @client.add_role_users(role_id, user_ids) if user_ids&.present?
      end

      def delete_role(name)
        role_id = find_role_id_by_name(name)
        @client.delete_role(role_id) if role_id
      end

      def remove_role_users(name, emails)
        role_id = find_role_id_by_name(name)
        user_ids = emails&.map { |email| find_user_id_by_email(email) }

        @client.remove_role_users(role_id, user_ids) if user_ids&.present?
      end

      def find_role_id_by_name(name)
        return unless (role = @roles.find { |_, r| r.name == name })

        role.last.id
      end

      def find_app_id_by_name(name)
        return unless (app = @apps.find { |_, a| a.name == name })

        app.last.id
      end

      def find_user_id_by_email(email)
        return unless (user = @users.find { |_, v| v.email == email })

        user.last.id
      end

      private

      def update_roles
        @roles = @client.list_roles(limit: 1000).to_h { |role| [role.name, role] }
      end
    end
  end
end

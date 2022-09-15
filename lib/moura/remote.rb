# frozen_string_literal: true

require "yaml"
require_relative "../onelogin/api"

module Moura
  class Remote
    def initialize
      OneLogin.configure do |config|
        config.host = "pepabo.onelogin.com"
        config.debugging = false
      end

      client_id = ENV.fetch("ONELOGIN_CLIENT_ID")
      client_secret = ENV.fetch("ONELOGIN_CLIENT_SECRET")
      @api = OneLogin::Api.new(client_id, client_secret)
    end

    def dump
      puts YAML.dump(roles.sort_by(&:first).to_h)
    end

    def users
      @users ||= users!
    end

    def users!
      # データを圧縮するために取得フィールドを絞る
      @api.list_users(fields: "id,email,firstname,lastname", limit: 1000).to_h do |user|
        [user.id, user]
      end
    end

    def roles
      @roles ||= roles!
    end

    def roles!
      @api.list_roles(limit: 1000).to_h do |role|
        emails = role.users.map do |id|
          users[id].email
        end
        [role.name, emails.sort]
      end
    end
  end
end

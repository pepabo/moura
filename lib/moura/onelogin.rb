# frozen_string_literal: true

require "onelogin"

module Moura
  module OneLogin
    def self.client
      ::OneLogin.configure do |config|
        config.host = ENV.fetch("ONELOGIN_API_DOMAIN")
        config.debugging = ENV.fetch("ONELOGIN_DEBUG", false)
      end

      client_id = ENV.fetch("ONELOGIN_CLIENT_ID")
      client_secret = ENV.fetch("ONELOGIN_CLIENT_SECRET")
      ::OneLogin::Api.new(client_id, client_secret)
    end
  end
end

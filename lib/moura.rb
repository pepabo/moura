# frozen_string_literal: true

require_relative "moura/cli"
require_relative "moura/version"

class Array
  def present?
    !empty?
  end
end

module Moura
  class Error < StandardError; end

  class RoleNotFound < Error
    def initialize(role)
      super("role '#{role}' does not exist")
    end
  end

  class UserNotFound < Error
    def initialize(user)
      super("user '#{user}' does not exist")
    end
  end

  class ApplicationNotFound < Error
    def initialize(app)
      super("application '#{app}' does not exist")
    end
  end

  def self.start(_argv = ARGV)
    Cli.start(ARGV)
  end
end

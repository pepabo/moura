# frozen_string_literal: true

require_relative "moura/cli"
require_relative "moura/version"

module Moura
  class Error < StandardError; end

  def self.start(_argv = ARGV)
    Cli.start(ARGV)
  end
end

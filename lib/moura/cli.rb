# frozen_string_literal: true

require "thor"
require_relative "remote"

module Moura
  class Cli < Thor
    desc "dump", "dump"
    def dump
      remote = Remote.new
      remote.dump
    end
  end
end

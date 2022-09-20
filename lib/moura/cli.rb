# frozen_string_literal: true

require "thor"
require_relative "model/diff"
require_relative "view"

module Moura
  class Cli < Thor
    desc "dump", "dump"
    def dump
      remote = Remote.new
      remote.dump
    end

    desc "diff <file>", "diff"
    def diff(file)
      model = Model::Diff.new(file)

      View::Diff.new(model.diff).show
    end
  end
end

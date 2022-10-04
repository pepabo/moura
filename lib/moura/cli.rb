# frozen_string_literal: true

require "thor"
require_relative "model/diff"
require_relative "view"

module Moura
  class Cli < Thor
    desc "dump", "dump"
    def dump
      role_users = Model::Remote.role_users
      puts YAML.dump(role_users.sort_by(&:first).to_h)
    end

    desc "diff <file>", "diff"
    def diff(file)
      model = Model::Diff.new(file)

      View::Diff.new(model.diff).show
    end

    desc "apply <file>", "diff"
    def apply(file)
      model = Model::Diff.new(file)
      model.apply

      View::Diff.new(model.diff).show
    end
  end
end

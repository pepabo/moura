# frozen_string_literal: true

require "yaml"

module Moura
  module Model
    class Local
      def initialize(file)
        @roles = YAML.load_file(file, aliases: true).sort_by(&:first).to_h do |(k, v)|
          apps = v["apps"] || []
          users = v["users"] || []

          [k, { "apps" => apps.sort.uniq, "users" => users.sort.uniq }]
        end
      end

      def dump
        @roles
      end
    end
  end
end

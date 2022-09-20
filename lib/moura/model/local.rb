# frozen_string_literal: true

require "yaml"

module Moura
  module Model
    class Local
      attr_reader :roles

      def initialize(file)
        @roles = YAML.unsafe_load_file(file).sort_by(&:first).to_h do |(k, v)|
          sorted = v&.sort || []
          [k, sorted.uniq]
        end
      end
    end
  end
end

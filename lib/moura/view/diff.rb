# frozen_string_literal: true

module Moura
  module View
    class Diff
      attr :data

      def initialize(diff)
        @data = diff
      end

      def show
        data.to_h.each do |role, attr|
          role_action = case attr[:action]
                        when :add then "+"
                        when :remove then "-"
                        else " "
                        end
          puts "#{role_action} #{role}:"

          [
            [:add, "+"],
            [:remove, "-"]
          ].each do |action, mark|
            attr[:users][action]&.each do |user|
              puts "#{mark}   * #{user}"
            end
          end

          puts
        end
      end
    end
  end
end

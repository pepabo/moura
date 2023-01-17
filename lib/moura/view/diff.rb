# frozen_string_literal: true

module Moura
  module View
    class Diff
      attr :data

      def initialize(diff)
        @data = diff
      end

      def show
        @data.each do |role, attr|
          mark = symbol_to_mark(attr[:action])
          puts "#{mark} #{role}"
          show_child(attr[:apps], "アプリケーション")
          show_child(attr[:users], "ユーザ")
        end
      end

      def symbol_to_mark(sym)
        case sym
        when :add then "+"
        when :remove then "-"
        else " "
        end
      end

      def show_child(data, name)
        return if data[:add].empty? && data[:remove].empty?

        puts "    => #{name}"

        data[:add].sort.each do |a|
          puts "+      #{a}"
        end

        data[:remove].sort.each do |r|
          puts "-      #{r}"
        end
      end
    end
  end
end

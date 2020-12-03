# frozen_string_literal: true

require 'set'

module Gitlab
  module RackAttack
    class UserAllowlist
      def initialize(list)
        @set = Set.new

        (list || '').split(',').each do |id|
          @set << Integer(id)
        rescue ArgumentError
        end
      end

      def empty?
        @set.empty?
      end

      def include?(element)
        @set.include?(element)
      end
    end
  end
end

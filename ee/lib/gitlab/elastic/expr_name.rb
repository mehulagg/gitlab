# frozen_string_literal: true

module Gitlab
  module Elastic
    class ExprName < Array
      def self.build(*context)
        new(context)
      end

      def name(*context)
        return to_s if context.empty?

        ExprName.build(*self, *context).to_s
      end

      def to_s
        map(&:to_s).join(":")
      end
    end
  end
end

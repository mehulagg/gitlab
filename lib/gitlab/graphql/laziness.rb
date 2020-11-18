# frozen_string_literal: true

module Gitlab
  module Graphql
    module Laziness
      def defer(&block)
        ::Gitlab::Graphql::Lazy.new(&block)
      end

      def force(lazy)
        ::Gitlab::Graphql::Lazy.force(lazy)
      end
    end
  end
end

# frozen_string_literal: true

module Gitlab
  module Nav
    class TopNavMenuBuilder
      def initialize
        @primary = []
        @secondary = []
      end

      def add_primary_menu_item(**args)
        add_menu_item(@primary, **args)
      end

      def add_secondary_menu_item(**args)
        add_menu_item(@secondary, **args)
      end

      def build
        {
          primary: @primary.clone,
          secondary: @secondary.clone
        }
      end

      private

      def add_menu_item(dest, **args)
        item = ::Gitlab::Nav::TopNavMenuItem.new(**args)

        dest.push(item)

        self
      end
    end
  end
end

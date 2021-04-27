# frozen_string_literal: true

module Gitlab
  module Nav
    class TopNavViewModelBuilder
      def initialize
        @menu_builder = ::Gitlab::Nav::TopNavMenuBuilder.new
        @views = {}
      end

      def add_primary_menu_item(**args)
        @menu_builder.add_primary_menu_item(**args)

        self
      end

      def add_secondary_menu_item(**args)
        @menu_builder.add_secondary_menu_item(**args)

        self
      end

      def add_view(name, props)
        @views[name] = props

        self
      end

      def build
        menu = @menu_builder.build

        menu.merge({
          views: @views.clone.freeze,
          activeTitle: _('Menu')
        })
      end
    end
  end
end

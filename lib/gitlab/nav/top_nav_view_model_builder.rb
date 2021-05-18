# frozen_string_literal: true

module Gitlab
  module Nav
    class TopNavViewModelBuilder
      def initialize
        @menu_builder = ::Gitlab::Nav::TopNavMenuBuilder.new
        @views = {}
        @shortcuts = []
      end

      delegate :add_primary_menu_item, :add_secondary_menu_item, to: :@menu_builder

      def add_shortcut(**args)
        item = ::Gitlab::Nav::TopNavMenuItem.build(**args)

        @shortcuts.push(item)
      end

      def add_primary_menu_item_with_shortcut(shortcut_class:, shortcut_href: nil, **args)
        self.add_primary_menu_item(**args)
        self.add_shortcut(
          id: "#{args.fetch(:id)}-shortcut",
          title: args.fetch(:title),
          href: shortcut_href || args.fetch(:href),
          css_class: shortcut_class
        )
      end

      def add_view(name, props)
        @views[name] = props
      end

      def build
        menu = @menu_builder.build

        menu.merge({
          views: @views,
          shortcuts: @shortcuts,
          activeTitle: _('Menu')
        })
      end
    end
  end
end

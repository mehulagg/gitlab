# frozen_string_literal: true

module Sidebars
  class Panel
    extend ::Gitlab::Utils::Override

    attr_reader :current_user, :container, :context, :context_menu

    def initialize(context)
      @context = context
      @current_user = context.current_user
      @container = context.container
      @context_menu = nil
      @menus = []

      configure_menus
    end

    def configure_menus
      # No-op
    end

    def add_menu(menu)
      @menus << menu
    end

    def insert_menu_before(before_menu, new_menu)
      index = index_of(before_menu)

      if index
        @menus.insert(index, new_menu)
      else
        @menus.unshift(new_menu)
      end
    end

    def insert_menu_after(after_menu, new_menu)
      index = index_of(after_menu)

      if index
        @menus.insert(index + 1, new_menu)
      else
        add_menu(new_menu)
      end
    end

    def set_context_menu(context_menu)
      @context_menu = context_menu
    end

    def aria_label
      raise NotImplementedError
    end

    def has_renderable_menus?
      renderable_menus.any?
    end

    def renderable_menus
      @renderable_menus ||= @menus.select(&:render?)
    end

    private

    def index_of(menu)
      @menus.index { |m| m.is_a?(menu) }
    end
  end
end

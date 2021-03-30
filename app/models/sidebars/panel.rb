# frozen_string_literal: true

module Sidebars
  class Panel
    extend ::Gitlab::Utils::Override
    include ::Sidebars::PositionableList

    attr_reader :current_user, :container, :context, :scope_menu, :hidden_menu

    def initialize(context)
      @context = context
      @current_user = context.current_user
      @container = context.container
      @scope_menu = nil
      @hidden_menu = nil
      @menus = []

      configure_menus
    end

    def configure_menus
      # No-op
    end

    def add_menu(menu)
      add_element(@menus, menu)
    end

    def insert_menu_before(before_menu, new_menu)
      insert_element_before(@menus, before_menu, new_menu)
    end

    def insert_menu_after(after_menu, new_menu)
      insert_element_after(@menus, after_menu, new_menu)
    end

    def set_scope_menu(scope_menu)
      @scope_menu = scope_menu
    end

    def set_hidden_menu(hidden_menu)
      @hidden_menu = hidden_menu
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
  end
end

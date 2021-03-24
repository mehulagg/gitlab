# frozen_string_literal: true

module Sidebar
  class Panel
    attr_reader :current_user, :container, :context_menu

    def initialize(context)
      @context = context
      @current_user = context.current_user
      @container = context.container
      @context_menu = nil
      @menus = []
    end

    def add_menu(menu)
      @menus << menu
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
  end
end

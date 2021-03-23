# frozen_string_literal: true

module Sidebar
  class Panel
    attr_reader :container, :menus, :context_menu, :current_user

    def initialize(current_user, container)
      @current_user = current_user
      @context_menu = nil
      @menus = []
      @container = container
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

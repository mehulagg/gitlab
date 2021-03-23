# frozen_string_literal: true

module Sidebar
  class Menu
    extend ::Gitlab::Utils::Override
    include ::Gitlab::Routing

    attr_reader :current_user, :container, :items

    def initialize(current_user, container)
      @current_user = current_user
      @container = container
      @items = []
    end

    def render?
      true
    end

    def link_to_href
      raise NotImplementedError
    end

    def active_path
      raise NotImplementedError
    end

    def active_paths
      ([active_path] + renderable_items.map(&:active_path)).flatten
    end

    def link_to_attributes
      {}
    end

    def menu_name
      raise NotImplementedError
    end

    def has_renderable_items?
      renderable_items.any?
    end

    def add_item(item)
      @items << item
    end

    def renderable_items
      @renderable_items ||= items.select(&:render?)
    end

    def sprite_icon
      raise NotImplementedError
    end
  end
end

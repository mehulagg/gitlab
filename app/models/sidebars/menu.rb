# frozen_string_literal: true

module Sidebars
  class Menu
    extend ::Gitlab::Utils::Override
    include ::Gitlab::Routing
    include GitlabRoutingHelper
    include Gitlab::Allowable
    include ::Sidebars::HasPill
    include ::Sidebars::HasIcon
    include ::Sidebars::PositionableList

    attr_reader :context
    delegate :current_user, :container, to: :@context

    def initialize(context)
      @context = context
      @items = []

      configure_menu_items
    end

    def configure_menu_items
      # No-op
    end

    def render?
      @items.empty? || renderable_items.any?
    end

    def menu_link
      nil
    end

    def menu_container_html_options
      {
        title: menu_name
      }.merge(extra_menu_container_html_options)
    end

    def extra_menu_container_html_options
      {}
    end

    # This method normalizes the information retrieved from the submenus and this menu
    # Value from menus is something like: [{ path: 'foo', path: 'bar', controller: :foo }]
    # This method filters the information and returns: { path: ['foo', 'bar'], controller: :foo }
    def all_active_routes
      @all_active_routes ||= begin
        ([active_routes] + renderable_items.map(&:active_routes)).flatten.each_with_object({}) do |pairs, hash|
          pairs.each do |k, v|
            hash[k] ||= []
            hash[k] += Array(v)
            hash[k].uniq!
          end

          hash
        end
      end
    end

    def active_routes
      {}
    end

    def menu_name_html_options
      {}
    end

    def menu_name
      raise NotImplementedError
    end

    def has_items?
      @items.any?
    end

    def has_renderable_items?
      renderable_items.any?
    end

    def add_item(item)
      add_element(@items, item)
    end

    def insert_item_before(before_item, new_item)
      insert_element_before(@items, before_item, new_item)
    end

    def insert_item_after(after_item, new_item)
      insert_element_after(@items, after_item, new_item)
    end

    def renderable_items
      @renderable_items ||= @items.select(&:render?)
    end
  end
end

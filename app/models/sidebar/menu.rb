# frozen_string_literal: true

module Sidebar
  class Menu
    extend ::Gitlab::Utils::Override
    include ::Gitlab::Routing
    include GitlabRoutingHelper
    include Gitlab::Allowable

    def initialize(context)
      @context = context
      @items = []
    end

    def render?
      true
    end

    def link_to_href
      raise NotImplementedError
    end

    # This method normalizes the information retrieved from the submenus and this menu
    # Value from menus is something like: [{ path: 'foo', path: 'bar', controller: :foo }]
    # This method filters the information and returns: { path: ['foo', 'bar'], controller: :foo }
    def all_nav_link_params
      @all_nav_link_params ||= begin
        ([nav_link_params] + renderable_items.map(&:nav_link_params)).flatten.each_with_object({}) do |pairs, hash|
          pairs.each do |k, v|
            hash[k] ||= []
            hash[k] += Array(v)
            hash[k].uniq!
          end

          hash
        end
      end
    end

    def link_to_attributes
      {}
    end

    def nav_link_params
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
      @renderable_items ||= @items.select(&:render?)
    end

    def sprite_icon
      raise NotImplementedError
    end

    private

    def method_missing(method, *args, &block)
      @context.public_send(method) # rubocop:disable GitlabSecurity/PublicSend
    end
  end
end

# frozen_string_literal: true

module Sidebars
  class MenuItem
    extend ::Gitlab::Utils::Override
    include ::Gitlab::Routing
    include GitlabRoutingHelper
    include Gitlab::Allowable
    include ::Sidebars::HasIcon

    attr_reader :context

    def initialize(context)
      @context = context
    end

    def render?
      true
    end

    def item_link
      raise NotImplementedError
    end

    def item_container_html_options
      {
        title: item_name
      }.merge(extra_item_container_html_options)
    end

    def extra_item_container_html_options
      {}
    end

    # This method returns the possible values for the
    # nav_link helper method. It can be either `path`,
    # `page`, `controller`.
    # Param 'action' is not supported.
    def active_routes
      {}
    end

    def item_name
      raise NotImplementedError
    end
  end
end

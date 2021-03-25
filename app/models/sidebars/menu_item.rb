# frozen_string_literal: true

module Sidebars
  class MenuItem
    extend ::Gitlab::Utils::Override
    include ::Gitlab::Routing
    include GitlabRoutingHelper
    include Gitlab::Allowable
    include ::Sidebars::Linkable

    attr_reader :context

    def initialize(context)
      @context = context
    end

    def render?
      true
    end

    # This method returns the possible values for the
    # nav_link helper method. It can be either `path`,
    # `page`, `controller`.
    # Param 'action' is not supported.
    def nav_link_params
      raise NotImplementedError
    end

    def item_name
      raise NotImplementedError
    end
  end
end

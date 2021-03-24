# frozen_string_literal: true

module Sidebar
  class MenuItem
    extend ::Gitlab::Utils::Override
    include ::Gitlab::Routing
    include GitlabRoutingHelper
    include Gitlab::Allowable

    attr_reader :current_user, :container

    def initialize(current_user, container)
      @current_user = current_user
      @container = container
    end

    def render?
      true
    end

    def link_to_href
      raise NotImplementedError
    end

    def link_to_attributes
      {}
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

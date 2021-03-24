# frozen_string_literal: true

module Sidebar
  class MenuItem
    extend ::Gitlab::Utils::Override
    include ::Gitlab::Routing
    include GitlabRoutingHelper
    include Gitlab::Allowable

    def initialize(context)
      @context = context
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

    private

    def method_missing(method, *args, &block)
      # binding.pry if method != :container
      @context.public_send(method) # rubocop:disable GitlabSecurity/PublicSend
    end
  end
end

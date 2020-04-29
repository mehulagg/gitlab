# frozen_string_literal: true

module DependencyProxy
  class BaseService < ::ContainerBaseService
    private

    def registry
      DependencyProxy::Registry
    end

    def auth_headers
      {
        Authorization: "Bearer #{@token}"
      }
    end
  end
end

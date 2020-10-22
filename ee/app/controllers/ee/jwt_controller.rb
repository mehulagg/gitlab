# frozen_string_literal: true

module EE
  module JwtController
    extend ::Gitlab::Utils::Override

    SERVICES = {
      ::Auth::ContainerRegistryAuthenticationService::AUDIENCE => ::Auth::ContainerRegistryAuthenticationService,
      ::Auth::DependencyProxyAuthenticationService::AUDIENCE => ::Auth::DependencyProxyAuthenticationService
    }.freeze

    private

    override :services
    def services
      SERVICES
    end
  end
end

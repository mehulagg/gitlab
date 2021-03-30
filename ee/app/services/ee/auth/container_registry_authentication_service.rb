# frozen_string_literal: true

module EE
  module Auth
    module ContainerRegistryAuthenticationService
      extend ::Gitlab::Utils::Override

      private

      override :ensure_container_repository!
      def ensure_container_repository!(path, authorized_actions)
        return super unless ::Feature.enabled?(:container_registry_non_sticky_repository_creation, self, default_enabled: :yaml)

        ::Gitlab::Database::LoadBalancing::Session.without_sticky_writes { super }
      end

      override :can_access?
      def can_access?(requested_project, requested_action)
        if ::Gitlab.maintenance_mode? && requested_action != 'pull'
          @access_denied_in_maintenance_mode = true # rubocop:disable Gitlab/ModuleWithInstanceVariables
          return false
        end

        super
      end

      override :extra_info
      def extra_info
        return super unless access_denied_in_maintenance_mode?

        super.merge!({
          message: 'Write access denied in maintenance mode',
          write_access_denied_in_maintenance_mode: true
        })
      end

      def access_denied_in_maintenance_mode?
        @access_denied_in_maintenance_mode
      end
    end
  end
end

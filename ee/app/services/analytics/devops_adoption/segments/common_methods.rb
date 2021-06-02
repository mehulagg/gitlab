# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    module Segments
      module CommonMethods
        include Gitlab::Allowable

        def authorize!
          unless can?(current_user, :manage_devops_adoption_segments, namespace)
            raise AuthorizationError.new(self, 'Forbidden')
          end

          unless can?(current_user, :manage_devops_adoption_segments, display_namespace || :global)
            raise AuthorizationError.new(self, 'Forbidden')
          end
        end

        private

        attr_reader :current_user, :params

        def namespace
          params[:namespace]
        end

        def display_namespace
          params[:display_namespace]
        end
      end
    end
  end
end

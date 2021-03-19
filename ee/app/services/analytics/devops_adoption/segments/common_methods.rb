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
        end
      end
    end
  end
end

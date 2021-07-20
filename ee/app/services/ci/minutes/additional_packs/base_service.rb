# frozen_string_literal: true

module Ci
  module Minutes
    module AdditionalPacks
      class BaseService
        include BaseServiceUtility

        private

        # rubocop: disable Cop/UserAdmin
        def authorize_current_user!
          # Using #admin? is discouraged as it will bypass admin mode authorisation checks,
          # however those checks are not in place in our REST API yet, and this service is only
          # going to be used by the API for admin-only actions
          raise Gitlab::Access::AccessDeniedError unless current_user&.admin?
        end
        # rubocop: enable Cop/UserAdmin
      end
    end
  end
end

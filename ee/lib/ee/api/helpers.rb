module EE
  module API
    module Helpers
      def current_user
        strong_memoize(:current_user) do
          user = super

          ::Gitlab::Database::LoadBalancing::RackMiddleware
            .stick_or_unstick(env, :user, user.id) if user

          user
        end
      end

      def check_project_feature_available!(feature)
        not_found! unless user_project.feature_available?(feature)
      end
    end
  end
end

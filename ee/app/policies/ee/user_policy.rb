# frozen_string_literal: true

module EE
  module UserPolicy
    extend ActiveSupport::Concern

    prepended do
      condition(:updating_name_disabled_for_users, scope: :global) do
        ::License.feature_available?(:disable_name_update_for_users) &&
          ::Gitlab::CurrentSettings.current_application_settings.updating_name_disabled_for_users
      end

      condition(:can_remove_self, scope: :subject) do
        @subject.can_remove_self?
      end

      rule { can?(:update_user) }.enable :update_name

      rule { updating_name_disabled_for_users & ~admin }.prevent :update_name

      rule { user_is_self & ~can_remove_self }.prevent :destroy_user
    end
  end
end

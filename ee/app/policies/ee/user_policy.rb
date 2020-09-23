# frozen_string_literal: true

module EE
  module UserPolicy
    extend ActiveSupport::Concern

    prepended do
      condition(:updating_name_disabled_for_users) do
        ::License.feature_available?(:disable_name_update_for_users) &&
        ::Gitlab::CurrentSettings.current_application_settings.updating_name_disabled_for_users
      end

      rule { can?(:update_user) }.enable :update_name

      rule do
        updating_name_disabled_for_users &
        ~admin
      end.prevent :update_name
    end
  end
end

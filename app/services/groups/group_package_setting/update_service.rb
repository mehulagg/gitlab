# frozen_string_literal: true

module Groups
  module GroupPackageSetting
    class UpdateService < Groups::BaseService
      include Gitlab::Utils::StrongMemoize

      ALLOWED_ATTRIBUTES = %i[maven_duplicates_allowed maven_duplicate_exception_regex].freeze

      def execute
        return ServiceResponse.error(message: 'Access Denied', http_status: 403) unless allowed?

        if group_package_setting.update(group_package_setting_params)
          ServiceResponse.success(payload: { group_package_setting: group_package_setting })
        else
          ServiceResponse.error(
            message: group_package_setting.errors.full_messages.to_sentence || 'Bad request',
            http_status: 400
          )
        end
      end

      private

      def group_package_setting
        strong_memoize(:group_package_setting) do
          @group.group_package_setting || @group.build_group_package_setting
        end
      end

      def allowed?
        Ability.allowed?(current_user, :create_package_settings, @group)
      end

      def group_package_setting_params
        @params.slice(*ALLOWED_ATTRIBUTES)
      end
    end
  end
end

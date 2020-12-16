# frozen_string_literal: true

module Groups
  module PackageSettings
    class UpdateService < BaseService
      include Gitlab::Utils::StrongMemoize

      ALLOWED_ATTRIBUTES = %i[maven_duplicates_allowed maven_duplicate_exception_regex].freeze

      def execute
        return ServiceResponse.error(message: 'Access Denied', http_status: 403) unless allowed?

        if group.package_setting.update(package_setting_params)
          ServiceResponse.success(payload: { package_setting: package_setting })
        else
          ServiceResponse.error(
            message: package_setting.errors.full_messages.to_sentence || 'Bad request',
            http_status: 400
          )
        end
      end

      private

      def package_setting
        strong_memoize(:package_setting) do
          @container.package_setting || @container.build_package_setting
        end
      end

      def allowed?
        Ability.allowed?(current_user, :admin_group, @container)
      end

      def package_setting_params
        @params.slice(*ALLOWED_ATTRIBUTES)
      end
    end
  end
end

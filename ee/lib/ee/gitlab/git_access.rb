# frozen_string_literal: true

module EE
  module Gitlab
    module GitAccess
      prepend GeoGitAccess
      extend ::Gitlab::Utils::Override
      include PathLocksHelper
      include SubscribableBannerHelper

      override :check
      def check(cmd, changes)
        check_geo_license!
        check_smartcard_access!

        super
      end

      override :can_read_project?
      def can_read_project?
        return true if geo?

        super
      end

      def group?
        container.is_a?(Group)
      end

      def group
        container if group?
      end

      protected

      override :user
      def user
        return if geo?

        super
      end

      private

      override :check_custom_action
      def check_custom_action
        geo_custom_action || super
      end

      override :check_for_console_messages
      def check_for_console_messages
        super.push(
          *current_replication_lag_message
        )
      end

      override :check_download_access!
      def check_download_access!
        return if geo?

        super
      end

      override :check_change_access!
      def check_change_access!
        check_size_before_push!

        check_if_license_blocks_changes!

        super

        check_push_size!
      end

      override :check_active_user!
      def check_active_user!
        return if geo?

        super
      end

      def check_geo_license!
        if ::Gitlab::Geo.secondary? && !::Gitlab::Geo.license_allows?
          raise ::Gitlab::GitAccess::ForbiddenError, 'Your current license does not have GitLab Geo add-on enabled.'
        end
      end

      def check_smartcard_access!
        unless can_access_without_new_smartcard_login?
          raise ::Gitlab::GitAccess::ForbiddenError, 'Project requires smartcard login. Please login to GitLab using a smartcard.'
        end
      end

      def can_access_without_new_smartcard_login?
        return true unless user

        !::Gitlab::Auth::Smartcard::SessionEnforcer.new.access_restricted?(user)
      end

      def geo?
        actor == :geo
      end

      def check_if_license_blocks_changes!
        if ::License.block_changes?
          message = license_message(signed_in: true, is_admin: (user && user.admin?))
          raise ::Gitlab::GitAccess::ForbiddenError, strip_tags(message)
        end
      end

      def strip_tags(html)
        Rails::Html::FullSanitizer.new.sanitize(html)
      end

      override :check_size_limit?
      def check_size_limit?
        strong_memoize(:check_size_limit) do
          size_checker.enabled? && super
        end
      end
    end
  end
end

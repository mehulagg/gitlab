# frozen_string_literal: true

module Admin
  module NavbarHelper
    def navbar_controller_path
      cloud_license_enabled? ? 'admin/subscriptions' : 'admin/licenses'
    end

    def navbar_item_name
      cloud_license_enabled? ? _('Subscription') : _('License')
    end

    def navbar_item_path
      cloud_license_enabled? ? admin_subscription_path : admin_license_path
    end

    private

    def cloud_license_enabled?
      Gitlab::CurrentSettings.cloud_license_enabled?
    end
  end
end

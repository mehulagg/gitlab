# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::NavbarHelper do
  let_it_be(:current_user) { build(:user) }

  describe 'when cloud license is enabled' do
    before do
      stub_application_setting(cloud_license_enabled: true)
    end

    it 'returns the correct controller path' do
      expect(helper.navbar_controller_path).to eq('admin/subscriptions')
    end

    it 'returns the correct navbar item name' do
      expect(helper.navbar_item_name).to eq('Subscription')
    end

    it 'returns the correct navbar item path' do
      expect(helper.navbar_item_path).to eq(admin_subscription_path)
    end
  end

  describe 'when cloud license is not enabled' do
    before do
      stub_application_setting(cloud_license_enabled: false)
    end

    it 'returns the correct controller path' do
      expect(helper.navbar_controller_path).to eq('admin/licenses')
    end

    it 'returns the correct navbar item name' do
      expect(helper.navbar_item_name).to eq('License')
    end

    it 'returns the correct navbar item path' do
      expect(helper.navbar_item_path).to eq(admin_license_path)
    end
  end
end

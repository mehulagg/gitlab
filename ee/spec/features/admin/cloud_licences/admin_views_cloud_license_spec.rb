# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Admin views Cloud License', :js do
  let_it_be(:admin) { create(:admin) }

  before do
    sign_in(admin)
    gitlab_enable_admin_mode_sign_in(admin)
    stub_application_setting(cloud_license_enabled: true)
  end

  context 'Cloud license' do
    let_it_be(:license) { create_current_license(type: License::CLOUD_LICENSE_TYPE, plan: License::ULTIMATE_PLAN) }

    before do
      visit(admin_cloud_license_path)
    end

    it 'displays the subscription details' do
      page.within(find('#content-body', match: :first)) do
        expect(page).to have_content('Subscription details')
        expect(all("[data-testid='details-label']")[1]).to have_content('Plan:')
        expect(all("[data-testid='details-content']")[1]).to have_content('Ultimate')
      end
    end

    it 'succeeds to sync the subscription' do
      page.within(find('#content-body', match: :first)) do
        click_button('Sync subscription details')

        expect(page).to have_content('The subscription details synced successfully')
      end
    end

    it 'fails to sync the subscription' do
      create_current_license(type: License::CLOUD_LICENSE_TYPE, plan: License::ULTIMATE_PLAN, expires_at: nil)

      page.within(find('#content-body', match: :first)) do
        click_button('Sync subscription details')

        expect(page).to have_content('You can no longer sync your subscription details with GitLab. Get help for the most common connectivity issues by troubleshooting the activation code')
      end
    end
  end

  context 'when there is no license' do
    let_it_be(:license) { nil }

    before do
      allow(License).to receive(:current).and_return(license)

      visit(admin_cloud_license_path)
    end

    it 'displays a message signaling there is not active subscription' do
      page.within(find('#content-body', match: :first)) do
        expect(page).to have_content('You do not have an active subscription')
      end
    end
  end
end

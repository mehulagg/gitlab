# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Admin views Cloud License", :js do
  let_it_be(:admin) { create(:admin) }

  before do
    sign_in(admin)
    gitlab_enable_admin_mode_sign_in(admin)
    stub_application_setting(cloud_license_enabled: true)
    allow(License).to receive(:current).and_return(license)
  end

  context "when there is a license" do
    let_it_be(:license) { create(:license, plan: License::ULTIMATE_PLAN) }

    before do
      visit(admin_cloud_license_path)
    end

    it "shows the main title" do
      page.within(find('#content-body', match: :first)) do
        expect(page).to have_content("This instance is currently using the Ultimate Plan.")
      end
    end
  end

  context "when there is no license" do
    let_it_be(:license) { nil }

    before do
      visit(admin_cloud_license_path)
    end

    it "shows the main title" do
      page.within(find('#content-body', match: :first)) do
        expect(page).to have_content("This instance is currently using the Core Plan.")
      end
    end
  end
end

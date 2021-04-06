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

  License::EE_ALL_PLANS.each do |plan|
    context "#{plan} license" do
      let_it_be(:license) { build(:license, plan: plan) }

      it 'displays the correct license name' do
        visit(admin_cloud_license_path)

        page.within(find('#content-body', match: :first)) do
          expect(page).to have_content("This instance is currently using the #{plan.titleize} plan.")
        end
      end
    end
  end

  context "when there is no license" do
    let_it_be(:license) { nil }

    before do
      visit(admin_cloud_license_path)
    end

    it "displays the fallback license name" do
      page.within(find('#content-body', match: :first)) do
        expect(page).to have_content("This instance is currently using the Core plan.")
      end
    end
  end
end

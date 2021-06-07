# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Admin views license" do
  let_it_be(:admin) { create(:admin) }

  before do
    sign_in(admin)
    gitlab_enable_admin_mode_sign_in(admin)
    allow_any_instance_of(Gitlab::ExpiringSubscriptionMessage).to receive(:grace_period_effective_from).and_return(Date.today - 45.days)
  end

  context "when license is valid" do
    before do
      visit(admin_license_path)
    end

    it "shows license" do
      expect(page).to have_content("Your license is valid")

      page.within(".license-panel") do
        expect(page).to have_content("Unlimited")
      end
    end
  end

  context "when license is regular" do
    let_it_be(:license) { create(:license) }
    let_it_be(:reference_date) { Date.parse('2020-01-22') }

    context "when license is expired" do
      let_it_be(:license) { build(:license, data: build(:gitlab_license, expires_at: reference_date - 1.day).export).save!(validate: false) }

      it do
        travel_to(reference_date) do
          visit(admin_license_path)

          expect(page).to have_content("Your subscription expired!")
          expect(page).to have_link 'Renew subscription', href: "#{EE::SUBSCRIPTIONS_URL}/subscriptions"
        end
      end

      context "when license blocks changes" do
        let_it_be(:license) { build(:license, data: build(:gitlab_license, expires_at: reference_date - 1.week).export).save!(validate: false) }

        it do
          travel_to(reference_date) do
            visit(admin_license_path)

            expect(page).to have_content "You have 7 days to renew your subscription."
            expect(page).to have_link 'Renew subscription', href: "#{EE::SUBSCRIPTIONS_URL}/subscriptions"
          end
        end
      end

      context "when license blocks changes" do
        let_it_be(:license) { build(:license, data: build(:gitlab_license, expires_at: reference_date - 4.weeks, block_changes_at: reference_date - 1.day).export).save!(validate: false) }

        it do
          travel_to(reference_date) do
            visit(admin_license_path)

            expect(page).to have_content "You didn't renew your subscription so it was downgraded to the GitLab Core Plan"
            expect(page).to have_link 'Upgrade your plan', href: "#{EE::SUBSCRIPTIONS_URL}/subscriptions"
          end
        end
      end
    end

    context "when viewing license history", :aggregate_failures do
      before do
        visit(admin_license_path)
      end

      it "shows licensee" do
        license_history = page.find("#license_history")

        License.history.each do |license|
          expect(license_history).to have_content(license.licensee.each_value.first)
        end
      end

      it "highlights the current license with a css class", :aggregate_failures do
        license_history = page.find("#license_history")
        highlighted_license_row = license_history.find("[data-testid='license-current']")

        expect(highlighted_license_row).to have_content(license.licensee[:name])
        expect(highlighted_license_row).to have_content(license.licensee[:email])
        expect(highlighted_license_row).to have_content(license.licensee[:company])
        expect(highlighted_license_row).to have_content(license.plan.capitalize)
        expect(highlighted_license_row).to have_content(I18n.l(license.created_at, format: :with_timezone))
        expect(highlighted_license_row).to have_content(I18n.l(license.starts_at))
        expect(highlighted_license_row).to have_content(I18n.l(license.expires_at))
        expect(highlighted_license_row).to have_content(license.restrictions[:active_user_count])
      end
    end
  end

  context "with limited users" do
    let_it_be(:license) { create(:license, data: build(:gitlab_license, restrictions: { active_user_count: 2000 }).export) }

    before do
      visit(admin_license_path)
    end

    it "shows panel counts" do
      page.within(".license-panel") do
        expect(page).to have_content("2,000")
      end
    end
  end

  context "when existing licenses only contain a future-dated license" do
    let_it_be(:license) { create(:license, data: create(:gitlab_license, starts_at: Date.current + 1.month).export) }

    before do
      License.where.not(id: license.id).delete_all

      visit(admin_license_path)
    end

    context "when viewing license history" do
      it "shows licensee" do
        license_history = page.find("#license_history")

        expect(license_history).to have_content(license.licensee.each_value.first)
      end

      it "has no highlighted license", :aggregate_failures do
        license_history = page.find("#license_history")

        expect(license_history).not_to have_selector("[data-testid='license-current']")
      end

      it "shows only the future-dated license", :aggregate_failures do
        license_history = page.find("#license_history")
        license_history_row = license_history.find('tbody tr', match: :first)

        expect(license_history).to have_css('tbody tr', count: 1)

        expect(license_history_row).to have_content(license.licensee[:name])
        expect(license_history_row).to have_content(license.licensee[:email])
        expect(license_history_row).to have_content(license.licensee[:company])
        expect(license_history_row).to have_content(license.plan.capitalize)
        expect(license_history_row).to have_content(I18n.l(license.created_at, format: :with_timezone))
        expect(license_history_row).to have_content(I18n.l(license.starts_at))
        expect(license_history_row).to have_content(I18n.l(license.expires_at))
        expect(license_history_row).to have_content(license.restrictions[:active_user_count])
      end
    end
  end

  describe 'qrtly reconciliation alert', :js do
    shared_examples 'a visible alert' do
      it 'displays an alert' do
        expect(page).to have_selector('[data-testid="qrtly-reconciliation-alert"]')
      end
    end

    shared_examples 'a hidden alert' do
      it 'does not display an alert' do
        expect(page).not_to have_selector('[data-testid="qrtly-reconciliation-alert"]')
      end
    end

    context 'on dotcom' do
      before do
        allow(Gitlab).to receive(:com?).and_return(true)
        visit(admin_license_path)
      end

      it_behaves_like 'a hidden alert'
    end

    context 'on self-managed' do
      before do
        allow(Gitlab).to receive(:ee?).and_return(true)
      end

      context 'when qrtly reconciliation is available' do
        before do
          create(:upcoming_reconciliation, :self_managed)
          visit(admin_license_path)
        end

        it_behaves_like 'a visible alert'
      end

      context 'when qrtly reconciliation is not available' do
        before do
          visit(admin_license_path)
        end

        it_behaves_like 'a hidden alert'
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Billing plan pages', :feature, :js do
  include SubscriptionPortalHelpers

  let(:user) { create(:user) }
  let(:namespace) { user.namespace }
  let(:free_plan) { create(:free_plan) }
  let(:bronze_plan) { create(:bronze_plan) }
  let(:premium_plan) { create(:premium_plan) }
  let(:ultimate_plan) { create(:ultimate_plan) }

  let(:plans_data) do
    Gitlab::Json.parse(File.read(Rails.root.join('ee/spec/fixtures/gitlab_com_plans.json'))).map do |data|
      data.deep_symbolize_keys
    end
  end

  before do
    stub_feature_flags(show_billing_eoa_banner: true)
    stub_feature_flags(hide_deprecated_billing_plans: false)
    stub_experiment_for_subject(contact_sales_btn_in_app: true)
    stub_full_request("#{EE::SUBSCRIPTIONS_URL}/gitlab_plans?plan=#{plan.name}&namespace_id=#{namespace.id}")
      .to_return(status: 200, body: plans_data.to_json)
    stub_eoa_eligibility_request(namespace.id)
    stub_application_setting(check_namespace_plan: true)
    allow(Gitlab).to receive(:com?) { true }
    sign_in(user)
  end

  def external_upgrade_url(namespace, plan)
    if Plan::PAID_HOSTED_PLANS.include?(plan.name)
      "#{EE::SUBSCRIPTIONS_URL}/gitlab/namespaces/#{namespace.id}/upgrade/#{plan.name}-external-id"
    end
  end

  shared_examples 'does not display EoA banner' do
    it 'does not display the banner', :js do
      travel_to(Date.parse(EE::UserCalloutsHelper::EOA_BRONZE_PLAN_END_DATE) - 1.day) do
        visit page_path

        expect(page).not_to have_content("End of availability for the Bronze Plan")
      end
    end
  end

  shared_examples 'upgradable plan' do
    before do
      visit page_path
    end

    it 'displays the upgrade link' do
      page.within('.content') do
        expect(page).to have_link('Upgrade', href: external_upgrade_url(namespace, plan))
      end
    end
  end

  shared_examples 'can contact sales' do
    before do
      visit page_path
    end

    it 'displays the contact sales link' do
      # see ApplicationHelper#contact_sales_url
      contact_sales_url = 'https://about.gitlab.com/sales'
      page.within('.content') do
        expect(page).to have_link('Contact sales', href: %r{#{contact_sales_url}\?test=inappcontactsales(bronze|premium|gold)})
      end
    end
  end

  shared_examples 'non-upgradable plan' do
    before do
      visit page_path
    end

    it 'does not display the upgrade link' do
      page.within('.content') do
        expect(page).not_to have_link('Upgrade', href: external_upgrade_url(namespace, plan))
      end
    end
  end

  shared_examples 'downgradable plan' do
    before do
      visit page_path
    end

    it 'displays the downgrade link' do
      page.within('.content') do
        expect(page).to have_content('downgrade your plan')
        expect(page).to have_link('Customer Support', href: EE::CUSTOMER_SUPPORT_URL)
      end
    end
  end

  shared_examples 'plan with header' do
    before do
      visit page_path
    end

    it 'displays header' do
      page.within('.billing-plan-header') do
        expect(page).to have_content("#{user.username} you are currently using the #{plan.name.titleize} Plan.")

        expect(page).to have_css('.billing-plan-logo img')
      end
    end
  end

  shared_examples 'plan with subscription table' do
    before do
      visit page_path
    end

    it 'displays subscription table' do
      expect(page).to have_selector('.js-subscription-table')
    end
  end

  shared_examples 'used seats rendering for non paid subscriptions' do
    before do
      visit page_path
    end

    it 'displays the number of seats' do
      page.within('.js-subscription-table') do
        expect(page).to have_selector('p.property-value.gl-mt-2.gl-mb-0.number', text: '1')
      end
    end
  end

  shared_examples 'active deprecated plan' do
    let(:legacy_plan) { plans_data.find { |plan_data| plan_data[:id] == 'bronze-external-id' } }
    let(:expected_card_header) { "#{legacy_plan[:name]} (Legacy)" }

    before do
      stub_feature_flags(hide_deprecated_billing_plans: true)

      visit page_path
    end

    it 'renders the plan card marked as Legacy' do
      page.within('.billing-plans') do
        panels = page.all('.card')
        expect(panels.length).to eq(plans_data.length)

        panel_with_legacy_plan = page.find("[data-testid='plan-card-#{legacy_plan[:code]}']")

        expect(panel_with_legacy_plan.find('.card-header')).to have_content(expected_card_header)
        expect(panel_with_legacy_plan.find('.card-body')).to have_link('frequently asked questions')
      end
    end
  end

  shared_examples 'inactive deprecated plan' do
    let(:legacy_plan) { plans_data.find { |plan_data| plan_data[:id] == 'bronze-external-id' } }

    before do
      stub_feature_flags(hide_deprecated_billing_plans: true)

      visit page_path
    end

    it 'does not render the card for that plan' do
      expect(page).not_to have_selector("[data-testid='plan-card-#{legacy_plan[:code]}']")
    end
  end

  shared_examples 'plan with free upgrade' do
    before do
      visit page_path
    end

    it 'displays the free upgrade' do
      within '.card-badge' do
        expect(page).to have_text('Free upgrade!')
      end
    end
  end

  shared_examples 'plan with sales-assisted upgrade' do
    before do
      visit page_path
    end

    it 'displays the sales assisted offer' do
      within '.card-badge' do
        expect(page).to have_text('Upgrade offers available!')
      end
    end
  end

  context 'users profile billing page' do
    let(:page_path) { profile_billings_path }

    context 'on free' do
      let(:plan) { free_plan }

      before do
        visit page_path
      end

      it 'displays all plans' do
        page.within('.billing-plans') do
          panels = page.all('.card')

          expect(panels.length).to eq(plans_data.length)

          plans_data.each.with_index do |data, index|
            expect(panels[index].find('.card-header')).to have_content(data[:name])
          end
        end
      end

      it 'displays correct plan actions' do
        expected_actions = plans_data.map { |data| data.fetch(:purchase_link).fetch(:action) }
        plan_actions = page.all('.billing-plans .card .card-footer')
        expect(plan_actions.length).to eq(expected_actions.length)

        expected_actions.each_with_index do |expected_action, index|
          action = plan_actions[index]

          case expected_action
          when 'downgrade'
            expect(action).not_to have_link('Upgrade')
            expect(action).not_to have_css('.disabled')
          when 'current_plan'
            expect(action).not_to have_link('Upgrade')
          when 'upgrade'
            expect(action).to have_link('Upgrade')
            expect(action).not_to have_css('.disabled')
          end
        end
      end

      it_behaves_like 'plan with subscription table'
      it_behaves_like 'can contact sales'
    end

    context 'on bronze plan' do
      let(:plan) { bronze_plan }

      let!(:subscription) { create(:gitlab_subscription, namespace: namespace, hosted_plan: plan, seats: 15) }

      it 'shows the EoA bronze banner that can be dismissed permanently', :js do
        travel_to(Date.parse(EE::UserCalloutsHelper::EOA_BRONZE_PLAN_END_DATE) - 1.day) do
          visit page_path

          page.within(".js-eoa-bronze-plan-banner") do
            expect(page).to have_content("End of availability for the Bronze Plan")

            click_button "Dismiss"
          end

          visit page_path

          expect(page).not_to have_content("End of availability for the Bronze Plan")
        end
      end

      it_behaves_like 'plan with header'
      it_behaves_like 'downgradable plan'
      it_behaves_like 'upgradable plan'
      it_behaves_like 'can contact sales'
      it_behaves_like 'plan with subscription table'

      context 'when hide_deprecated_billing_plans is active' do
        let(:premium_plan_data) { plans_data.find { |plan_data| plan_data[:id] == 'premium-external-id' } }

        before do
          stub_feature_flags(hide_deprecated_billing_plans: true)
          stub_eoa_eligibility_request(namespace.id, true, premium_plan_data[:id])
        end

        it_behaves_like 'plan with free upgrade'
        it_behaves_like 'active deprecated plan'

        context 'with more than 25 users' do
          let!(:subscription) { create(:gitlab_subscription, namespace: namespace, hosted_plan: plan, seats: 30) }

          before do
            stub_eoa_eligibility_request(namespace.id, false, premium_plan_data[:id])
          end

          it_behaves_like 'plan with sales-assisted upgrade'
        end
      end
    end

    context 'on premium plan' do
      let(:plan) { premium_plan }

      let!(:subscription) { create(:gitlab_subscription, namespace: namespace, hosted_plan: plan, seats: 15) }

      it_behaves_like 'plan with header'
      it_behaves_like 'downgradable plan'
      it_behaves_like 'upgradable plan'
      it_behaves_like 'can contact sales'
      it_behaves_like 'plan with subscription table'
      it_behaves_like 'does not display EoA banner'
    end

    context 'on ultimate plan' do
      let(:plan) { ultimate_plan }

      let!(:subscription) { create(:gitlab_subscription, namespace: namespace, hosted_plan: plan, seats: 15) }

      it_behaves_like 'plan with header'
      it_behaves_like 'downgradable plan'
      it_behaves_like 'non-upgradable plan'
      it_behaves_like 'plan with subscription table'
      it_behaves_like 'does not display EoA banner'
    end
  end

  context 'users profile billing page with a trial' do
    let(:page_path) { profile_billings_path }

    context 'on free' do
      let(:plan) { free_plan }

      let!(:subscription) do
        create(:gitlab_subscription, namespace: namespace, hosted_plan: plan,
               trial: true, trial_ends_on: Date.current.tomorrow, seats: 15)
      end

      before do
        visit page_path
      end

      it 'displays all plans' do
        page.within('.billing-plans') do
          panels = page.all('.card')

          expect(panels.length).to eq(plans_data.length)

          plans_data.each.with_index do |data, index|
            expect(panels[index].find('.card-header')).to have_content(data[:name])
          end
        end
      end

      it 'displays correct plan actions' do
        expected_actions = plans_data.map { |data| data.fetch(:purchase_link).fetch(:action) }
        plan_actions = page.all('.billing-plans .card .card-footer')
        expect(plan_actions.length).to eq(expected_actions.length)

        expected_actions.each_with_index do |expected_action, index|
          action = plan_actions[index]

          case expected_action
          when 'downgrade'
            expect(action).not_to have_link('Upgrade')
            expect(action).not_to have_css('.disabled')
          when 'current_plan'
            expect(action).not_to have_css('.disabled')
          when 'upgrade'
            expect(action).to have_link('Upgrade')
            expect(action).not_to have_css('.disabled')
          end
        end
      end

      it_behaves_like 'can contact sales'
    end

    context 'on bronze plan' do
      let(:plan) { bronze_plan }

      let!(:subscription) { create(:gitlab_subscription, namespace: namespace, hosted_plan: plan, seats: 15) }

      it_behaves_like 'plan with header'
      it_behaves_like 'downgradable plan'
      it_behaves_like 'upgradable plan'
      it_behaves_like 'can contact sales'
    end

    context 'on ultimate plan' do
      let(:plan) { ultimate_plan }

      let!(:subscription) { create(:gitlab_subscription, namespace: namespace, hosted_plan: plan, seats: 15) }

      it_behaves_like 'plan with header'
      it_behaves_like 'downgradable plan'
      it_behaves_like 'non-upgradable plan'
    end
  end

  context 'group billing page' do
    let(:namespace) { create(:group) }
    let!(:group_member) { create(:group_member, :owner, group: namespace, user: user) }

    context 'top-most group' do
      let(:page_path) { group_billings_path(namespace) }

      context 'on ultimate' do
        let(:plan) { ultimate_plan }

        let!(:subscription) { create(:gitlab_subscription, namespace: namespace, hosted_plan: plan, seats: 15) }

        before do
          visit page_path
        end

        it 'displays plan header' do
          page.within('.billing-plan-header') do
            expect(page).to have_content("#{namespace.name} is currently using the Ultimate Plan")

            expect(page).to have_css('.billing-plan-logo .identicon')
          end
        end

        it 'does not display the billing plans table' do
          expect(page).not_to have_css('.billing-plans')
        end

        it_behaves_like 'plan with subscription table'
      end

      context 'on bronze' do
        let(:plan) { bronze_plan }

        let!(:subscription) { create(:gitlab_subscription, namespace: namespace, hosted_plan: plan, seats: 15) }

        before do
          visit page_path
        end

        it 'displays plan header' do
          page.within('.billing-plan-header') do
            expect(page).to have_content("#{namespace.name} is currently using the Bronze Plan")

            expect(page).to have_css('.billing-plan-logo .identicon')
          end
        end

        it 'does display the billing plans table' do
          expect(page).to have_css('.billing-plans')
        end

        it_behaves_like 'can contact sales'
        it_behaves_like 'plan with subscription table'
      end

      context 'on free' do
        let(:plan) { free_plan }

        it_behaves_like 'used seats rendering for non paid subscriptions'
      end

      context 'on trial' do
        let(:plan) { premium_plan }

        let!(:subscription) do
          create(:gitlab_subscription, namespace: namespace, hosted_plan: plan,
                 trial: true, trial_ends_on: Date.current.tomorrow, seats: 15)
        end

        before do
          stub_full_request("#{EE::SUBSCRIPTIONS_URL}/gitlab_plans?plan=free&namespace_id=#{namespace.id}")
            .to_return(status: 200, body: plans_data.to_json)

          visit page_path
        end

        it 'displays the billing plans table' do
          expect(page).to have_css('.billing-plans')
        end

        it_behaves_like 'non-upgradable plan'
        it_behaves_like 'used seats rendering for non paid subscriptions'
        it_behaves_like 'plan with subscription table'
      end
    end
  end

  context 'with unexpected JSON' do
    let(:plan) { free_plan }

    let(:plans_data) do
      [
        {
          name: "Superhero",
          price_per_month: 999.0,
          free: true,
          code: "not-found",
          price_per_year: 111.0,
          purchase_link: {
            action: "upgrade",
            href: "http://customers.test.host/subscriptions/new?plan_id=super_hero_id"
          },
          features: []
        }
      ]
    end

    before do
      visit profile_billings_path
    end

    it 'renders no header for missing plan' do
      expect(page).not_to have_css('.billing-plan-header')
    end

    it 'displays all plans' do
      page.within('.billing-plans') do
        panels = page.all('.card')
        expect(panels.length).to eq(plans_data.length)
        plans_data.each_with_index do |data, index|
          expect(panels[index].find('.card-header')).to have_content(data[:name])
        end
      end
    end
  end
end

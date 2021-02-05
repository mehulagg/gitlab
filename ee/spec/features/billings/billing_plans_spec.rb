# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Billing plan pages', :feature do
  include StubRequests
  include SubscriptionPortalHelpers

  let(:user) { create(:user) }
  let(:namespace) { user.namespace }
  let(:free_plan) { create(:free_plan) }
  let(:bronze_plan) { create(:bronze_plan) }
  let(:silver_plan) { create(:silver_plan) }
  let(:gold_plan) { create(:gold_plan) }
  let(:plans_data) do
    Gitlab::Json.parse(File.read(Rails.root.join('ee/spec/fixtures/gitlab_com_plans.json'))).map do |data|
      data.deep_symbolize_keys
    end
  end

  before do
    stub_feature_flags(hide_deprecated_billing_plans: false)
    stub_experiment_for_subject(contact_sales_btn_in_app: true)
    stub_full_request("#{EE::SUBSCRIPTIONS_URL}/gitlab_plans?plan=#{plan.name}&namespace_id=#{namespace.id}")
      .to_return(status: 200, body: plans_data.to_json)
    stub_eoa_eligibility_request(namespace.id)
    stub_application_setting(check_namespace_plan: true)
    allow(Gitlab).to receive(:com?) { true }
    gitlab_sign_in(user)
  end

  def external_upgrade_url(namespace, plan)
    if Plan::PAID_HOSTED_PLANS.include?(plan.name)
      "#{EE::SUBSCRIPTIONS_URL}/gitlab/namespaces/#{namespace.id}/upgrade/#{plan.name}-external-id"
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
        expect(page).to have_link('Contact sales', href: %r{#{contact_sales_url}\?test=inappcontactsales(bronze|silver|gold)})
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
        expect(page).to have_content("#{user.username} you are currently using the #{plan.name.titleize} plan.")

        expect(page).to have_css('.billing-plan-logo img')
      end
    end
  end

  shared_examples 'plan with subscription table' do
    before do
      visit page_path
    end

    it 'displays subscription table', :js do
      expect(page).to have_selector('.js-subscription-table')
    end
  end

  shared_examples 'used seats rendering for non paid subscriptions' do
    before do
      visit page_path
    end

    it 'displays the number of seats', :js do
      page.within('.js-subscription-table') do
        expect(page).to have_selector('p.property-value.gl-mt-2.gl-mb-0.number', text: '1')
      end
    end
  end

  context 'users profile billing page' do
    let(:page_path) { profile_billings_path }

    context 'on free' do
      let(:plan) { free_plan }

      let!(:subscription) do
        create(:gitlab_subscription, namespace: namespace, hosted_plan: plan, seats: 15)
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

      let!(:subscription) do
        create(:gitlab_subscription, namespace: namespace, hosted_plan: plan, seats: 15)
      end

      it_behaves_like 'plan with header'
      it_behaves_like 'downgradable plan'
      it_behaves_like 'upgradable plan'
      it_behaves_like 'can contact sales'
      it_behaves_like 'plan with subscription table'
    end

    context 'on silver plan' do
      let(:plan) { silver_plan }

      let!(:subscription) do
        create(:gitlab_subscription, namespace: namespace, hosted_plan: plan, seats: 15)
      end

      it_behaves_like 'plan with header'
      it_behaves_like 'downgradable plan'
      it_behaves_like 'upgradable plan'
      it_behaves_like 'can contact sales'
      it_behaves_like 'plan with subscription table'
    end

    context 'on gold plan' do
      let(:plan) { gold_plan }

      let!(:subscription) do
        create(:gitlab_subscription, namespace: namespace, hosted_plan: plan, seats: 15)
      end

      it_behaves_like 'plan with header'
      it_behaves_like 'downgradable plan'
      it_behaves_like 'non-upgradable plan'
      it_behaves_like 'plan with subscription table'
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

      let!(:subscription) do
        create(:gitlab_subscription, namespace: namespace, hosted_plan: plan, seats: 15)
      end

      it_behaves_like 'plan with header'
      it_behaves_like 'downgradable plan'
      it_behaves_like 'upgradable plan'
      it_behaves_like 'can contact sales'
    end

    context 'on gold plan' do
      let(:plan) { gold_plan }

      let!(:subscription) do
        create(:gitlab_subscription, namespace: namespace, hosted_plan: plan, seats: 15)
      end

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

      context 'on gold' do
        let(:plan) { gold_plan }

        let!(:subscription) do
          create(:gitlab_subscription, namespace: namespace, hosted_plan: plan, seats: 15)
        end

        before do
          visit page_path
        end

        it 'displays plan header' do
          page.within('.billing-plan-header') do
            expect(page).to have_content("#{namespace.name} is currently using the Gold Plan")

            expect(page).to have_css('.billing-plan-logo .identicon')
          end
        end

        it 'does not display the billing plans table' do
          expect(page).not_to have_css('.billing-plans')
        end

        it 'displays subscription table', :js do
          expect(page).to have_selector('.js-subscription-table')
        end
      end

      context 'on bronze' do
        let(:plan) { bronze_plan }

        let!(:subscription) do
          create(:gitlab_subscription, namespace: namespace, hosted_plan: plan, seats: 15)
        end

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

        it 'displays subscription table', :js do
          expect(page).to have_selector('.js-subscription-table')
        end

        it_behaves_like 'can contact sales'
      end

      context 'on free' do
        let(:plan) { free_plan }
        let!(:subscription) { create(:gitlab_subscription, namespace: namespace, hosted_plan: plan) }

        it_behaves_like 'used seats rendering for non paid subscriptions'
      end
    end
  end

  context 'group billing page with a trial' do
    let(:namespace) { create(:group) }
    let!(:group_member) { create(:group_member, :owner, group: namespace, user: user) }

    before do
      stub_full_request("#{EE::SUBSCRIPTIONS_URL}/gitlab_plans?plan=free&namespace_id=#{namespace.id}")
        .to_return(status: 200, body: plans_data.to_json)
    end

    context 'top-most group' do
      let(:page_path) { group_billings_path(namespace) }

      context 'on gold' do
        let(:plan) { gold_plan }

        let!(:subscription) do
          create(:gitlab_subscription, namespace: namespace, hosted_plan: plan,
                 trial: true, trial_ends_on: Date.current.tomorrow, seats: 15)
        end

        before do
          visit page_path
        end

        it 'displays plan header' do
          page.within('.billing-plan-header') do
            expect(page).to have_content("#{namespace.name} is currently using the Gold Plan")

            expect(page).to have_css('.billing-plan-logo .identicon')
          end
        end

        it 'does display the billing plans table' do
          expect(page).to have_css('.billing-plans')
        end

        it 'displays subscription table', :js do
          expect(page).to have_selector('.js-subscription-table')
        end

        it_behaves_like 'non-upgradable plan'
        it_behaves_like 'used seats rendering for non paid subscriptions'
      end
    end
  end

  context 'on sub-group' do
    let(:group) { create(:group_with_plan, plan: :bronze_plan) }
    let(:plan) { bronze_plan }
    let(:namespace) { group }

    let!(:group_member) { create(:group_member, :owner, group: group, user: user) }

    let(:subgroup1) { create(:group, parent: group) }
    let!(:subgroup1_member) { create(:group_member, :owner, group: subgroup1) }

    let(:subgroup2) { create(:group, parent: subgroup1) }
    let!(:subgroup2_member) { create(:group_member, :owner, group: subgroup2) }

    let(:page_path) { group_billings_path(subgroup2) }

    before do
      visit page_path
    end

    it 'displays plan header' do
      page.within('.billing-plan-header') do
        expect(page).to have_content("#{subgroup2.full_name} is currently using the Bronze Plan")
        expect(page).to have_css('.billing-plan-logo .identicon')
        expect(page.find('.btn-success')).to have_content('Manage plan')
      end

      expect(page).not_to have_css('.billing-plans')
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

  context 'when ff purchase_deprecated_plans is enabled' do
    before do
      stub_feature_flags(hide_deprecated_billing_plans: true)
    end

    context 'when deprecated plan is active' do
      let(:plan) { bronze_plan }
      let!(:subscription) do
        create(:gitlab_subscription, namespace: namespace, hosted_plan: plan, seats: 15)
      end

      let(:expected_card_header) { "#{plans_data[1][:name]} (Legacy)" }

      it 'renders the plan card marked as Legacy' do
        visit profile_billings_path

        page.within('.billing-plans') do
          panels = page.all('.card')
          expect(panels.length).to eq(plans_data.length)

          panel_with_legacy_plan = panels[1] # free [0], bronze [1]

          expect(panel_with_legacy_plan.find('.card-header')).to have_content(expected_card_header)
          expect(panel_with_legacy_plan.find('.card-body')).to have_link('frequently asked questions')
        end
      end
    end

    context 'when deprecated plan is inactive' do
      let(:plan) { free_plan }

      it 'does not render the card for that plan' do
        visit profile_billings_path

        page.within('.billing-plans') do
          panels = page.all('.card')
          expect(panels.length).to eq(plans_data.length - 1)
        end
      end
    end
  end
end

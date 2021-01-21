# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Groups > Billing', :js do
  include StubRequests

  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:bronze_plan) { create(:bronze_plan) }

  def formatted_date(date)
    date.strftime("%B %-d, %Y")
  end

  def subscription_table
    '.subscription-table'
  end

  before do
    stub_full_request("#{EE::SUBSCRIPTIONS_URL}/gitlab_plans?plan=#{plan}&namespace_id=#{group.id}")
      .with(headers: { 'Accept' => 'application/json' })
      .to_return(status: 200, body: File.new(Rails.root.join('ee/spec/fixtures/gitlab_com_plans.json')))

    allow(Gitlab).to receive(:com?).and_return(true)
    stub_application_setting(check_namespace_plan: true)

    group.add_owner(user)
    sign_in(user)
  end

  context 'with a free plan' do
    let(:plan) { 'free' }

    let!(:subscription) do
      create(:gitlab_subscription, namespace: group, hosted_plan: nil, seats: 15)
    end

    it 'shows the proper title and subscription data' do
      visit group_billings_path(group)

      expect(page).to have_content("#{group.name} is currently using the Free plan")
      within subscription_table do
        expect(page).to have_content("start date #{formatted_date(subscription.start_date)}")
        expect(page).to have_link("Upgrade", href: "#{EE::SUBSCRIPTIONS_URL}/subscriptions")
        expect(page).not_to have_link("Manage")
      end
    end
  end

  context 'with a paid plan' do
    let(:plan) { 'bronze' }

    let_it_be(:subscription) do
      create(:gitlab_subscription, namespace: group, hosted_plan: bronze_plan, seats: 15)
    end

    it 'shows the proper title and subscription data' do
      extra_seats_url = "#{EE::SUBSCRIPTIONS_URL}/gitlab/namespaces/#{group.id}/extra_seats"
      renew_url = "#{EE::SUBSCRIPTIONS_URL}/gitlab/namespaces/#{group.id}/renew"
      upgrade_url =
        "#{EE::SUBSCRIPTIONS_URL}/gitlab/namespaces/#{group.id}/upgrade/bronze-external-id"

      visit group_billings_path(group)

      expect(page).to have_content("#{group.name} is currently using the Bronze plan")
      within subscription_table do
        expect(page).to have_content("start date #{formatted_date(subscription.start_date)}")
        expect(page).to have_link("Upgrade", href: upgrade_url)
        expect(page).to have_link("Manage", href: "#{EE::SUBSCRIPTIONS_URL}/subscriptions")
        expect(page).to have_link("Add seats", href: extra_seats_url)
        expect(page).to have_link("Renew", href: renew_url)
        expect(page).to have_link("See usage", href: group_seat_usage_path(group))
      end
    end

    context 'with disabled feature flags' do
      before do
        stub_feature_flags(saas_manual_renew_button: false)
        stub_feature_flags(saas_add_seats_button: false)
        visit group_billings_path(group)
      end

      it 'does not show "Add Seats" button' do
        within subscription_table do
          expect(page).not_to have_link("Add seats")
          expect(page).not_to have_link("Renew")
        end
      end
    end
  end

  context 'with a legacy paid plan' do
    let(:plan) { 'bronze' }

    let!(:subscription) do
      create(:gitlab_subscription, end_date: 1.week.ago, namespace: group, hosted_plan: bronze_plan, seats: 15)
    end

    it 'shows the proper title and subscription data' do
      visit group_billings_path(group)

      expect(page).to have_content("#{group.name} is currently using the Bronze plan")
      within subscription_table do
        expect(page).not_to have_link("Upgrade")
        expect(page).to have_link("Manage", href: "#{EE::SUBSCRIPTIONS_URL}/subscriptions")
      end
    end
  end

  context 'with feature flags' do
    using RSpec::Parameterized::TableSyntax

    where(:saas_manual_renew_button, :saas_add_seats_button) do
      true | true
      true | false
      false | true
      false | false
    end

    let(:plan) { 'bronze' }

    let_it_be(:subscription) do
      create(:gitlab_subscription, namespace: group, hosted_plan: bronze_plan, seats: 15)
    end

    with_them do
      before do
        stub_feature_flags(saas_manual_renew_button: saas_manual_renew_button)
        stub_feature_flags(saas_add_seats_button: saas_add_seats_button)
      end

      it 'pushes the correct feature flags' do
        visit group_billings_path(group)

        expect(page).to have_pushed_frontend_feature_flags(
          saasAddSeatsButton: saas_add_seats_button,
          saasManualRenewButton: saas_manual_renew_button
        )
      end
    end
  end
end

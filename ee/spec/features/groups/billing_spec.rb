# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Groups > Billing', :js do
  include StubRequests

  let!(:user)        { create(:user) }
  let!(:group)       { create(:group) }
  let!(:bronze_plan) { create(:bronze_plan) }

  def formatted_date(date)
    date.strftime("%B %-d, %Y")
  end

  def subscription_table
    '.subscription-table'
  end

  before do
    stub_full_request("#{EE::SUBSCRIPTIONS_URL}/gitlab_plans?plan=#{plan}")
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

    let!(:subscription) do
      create(:gitlab_subscription, namespace: group, hosted_plan: bronze_plan, seats: 15)
    end

    it 'shows the proper title and subscription data' do
      visit group_billings_path(group)

      upgrade_url =
        "#{EE::SUBSCRIPTIONS_URL}/gitlab/namespaces/#{group.id}/upgrade/bronze-external-id"

      expect(page).to have_content("#{group.name} is currently using the Bronze plan")
      within subscription_table do
        expect(page).to have_content("start date #{formatted_date(subscription.start_date)}")
        expect(page).to have_link("Upgrade", href: upgrade_url)
        expect(page).to have_link("Manage", href: "#{EE::SUBSCRIPTIONS_URL}/subscriptions")
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
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'layouts/header/_ee_subscribable_banner' do
  let(:group) { build(:group) }
  let(:gitlab_subscription_or_license) { build(:gitlab_license, expires_at: Date.current - 1.month) }
  let(:gitlab_subscription_message_or_license_message) { double(:message) }

  before do
    allow(view).to receive(:gitlab_subscription_or_license).and_return(gitlab_subscription_or_license)
    allow(view).to receive(:gitlab_subscription_message_or_license_message).and_return(gitlab_subscription_message_or_license_message)
    render
  end

  it 'shows the renew plan link' do
    expect(rendered).to have_link 'Upgrade your plan', href: plan_renew_url(:group)
  end
end

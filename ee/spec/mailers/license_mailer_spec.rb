# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LicenseMailer do
  include EmailSpec::Matchers

  let(:recipients) { %w(bob@example.com john@example.com) }
  let(:license) { create(:license, plan: License::STARTER_PLAN, restrictions: { active_user_count: 21 }) }

  before do
    allow(License).to receive(:current).and_return(license)
    allow(License.current).to receive(:current_active_users_count).and_return(active_user_count)
  end

  shared_examples 'mail format' do
    it { is_expected.to have_subject subject_text }
    it { is_expected.to bcc_to recipients }
    it { is_expected.to have_body_text "your subscription #{subscription_name}" }
    it { is_expected.to have_body_text "You have #{active_user_count}" }
    it { is_expected.to have_body_text "the user limit of #{license.restricted_user_count}" }
  end

  describe '#approaching_active_user_count_limit' do
    let(:subject_text) { "Your subscription is nearing its user limit" }
    let(:subscription_name) { "GitLab Enterprise Edition Starter" }
    let(:active_user_count) { 20 }

    subject { described_class.approaching_active_user_count_limit(recipients) }

    it_behaves_like 'mail format'
  end
end

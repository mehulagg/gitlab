# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Namespaces::OnboardingIssueCreatedWorker, '#perform' do
  let_it_be(:issue) { create(:issue) }
  let(:namespace) { issue.namespace }

  it_behaves_like 'records an onboarding progress action', :issue_created do
    subject { described_class.new.perform(namespace.id) }
  end

  it_behaves_like 'does not record an onboarding progress action' do
    subject { described_class.new.perform(nil) }
  end

  it_behaves_like 'an idempotent worker' do
    let(:job_args) { [namespace.id] }
  end
end

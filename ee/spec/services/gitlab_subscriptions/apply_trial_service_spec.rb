# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSubscriptions::ApplyTrialService do
  subject(:execute) { described_class.new.execute(apply_trial_params) }

  let_it_be(:namespace) { create(:namespace) }
  let(:apply_trial_params) do
    {
      trial_user: {
        namespace_id: namespace.id
      }
    }
  end

  describe '#execute' do
    before do
      allow(Gitlab::SubscriptionPortal::Client).to receive(:generate_trial).and_return(response)
    end

    context 'trial applied successfully' do
      let(:response) { { success: true }}

      it 'returns success: true' do
        expect(execute).to eq({ success: true })
      end

      it 'records a namespace onboarding progress action' do
        expect_next_instance_of(OnboardingProgressService) do |service|
          expect(service).to receive(:execute).with(action: :trial_started)
        end

        execute
      end
    end

    context 'error while applying the trial' do
      let(:response) { { success: false, data: { errors: ['some error'] } }}

      it 'returns success: false with errors' do
        expected_response = {
          success: false,
          errors: ['some error']
        }

        expect(execute).to eq(expected_response)
      end

      it 'does not record a namespace onboarding progress action' do
        expect(OnboardingProgressService).not_to receive(:new)

        execute
      end
    end
  end
end

# frozen_string_literal: true

# Requires `project`, `users`, `fingerprint`, and `resolving_payload`
RSpec.shared_examples 'oncall users are correctly notified' do
  context 'with feature enabled' do
    before do
      stub_licensed_features(oncall_schedules: project)
    end

    it_behaves_like 'Alert Notification Service sends notification email to on-call users'

    context 'when alert with the same fingerprint already exists' do
      let!(:alert) { create(:alert_management_alert, status, fingerprint: fingerprint, project: project) }

      it_behaves_like 'Alert Notification Service sends notification email to on-call users' do
        let(:status) { :triggered }
      end

      it_behaves_like 'Alert Notification Service sends no notifications' do
        let(:status) { :acknowledged }
      end

      it_behaves_like 'Alert Notification Service sends notification email to on-call users' do
        let(:status) { :resolved }
      end

      it_behaves_like 'Alert Notification Service sends no notifications' do
        let(:status) { :ignored }
      end

      context 'with resolving payload' do
        let(:status) { :triggered }
        let(:payload) { resolving_payload }

        it_behaves_like 'Alert Notification Service sends notification email to on-call users'
      end
    end
  end

  context 'with feature disabled' do
    it_behaves_like 'Alert Notification Service sends no notifications'
  end
end

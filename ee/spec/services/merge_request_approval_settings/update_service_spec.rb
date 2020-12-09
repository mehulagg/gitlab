# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequestApprovalSettings::UpdateService do
  let_it_be(:namespace) { create(:namespace) }
  let_it_be(:user) { create(:user) }
  let(:params) { { allow_author_approval: false } }

  subject(:service) do
    described_class.new(
      container: namespace,
      current_user: user,
      params: params
    )
  end

  describe 'execute' do
    context 'user does not have permissions' do
      before do
        allow(service).to receive(:can?).with(user, :modify_merge_request_approval_settings, namespace).and_return(false)
      end

      it 'responds with an error response', :aggregate_failures do
        response = subject.execute

        expect(response.status).to eq(:error)
        expect(response.message).to eq('Insufficient permissions')
      end
    end

    context 'user has permissions' do
      before do
        allow(service).to receive(:can?).with(user, :modify_merge_request_approval_settings, namespace).and_return(true)
      end

      it 'creates a new setting' do
        expect { subject.execute }.to change { MergeRequestApprovalSetting.count }.by(1)
      end

      it 'responds with a successful service response', :aggregate_failures do
        response = subject.execute

        expect(response).to be_success
        expect(response.payload.allow_author_approval).to be false
      end

      context 'when namespace has an existing setting' do
        let_it_be(:namespace) { create(:namespace) }
        let_it_be(:existing_setting) { create(:merge_request_approval_setting, namespace: namespace) }

        it 'does not create a new setting' do
          expect { subject.execute }
            .to change { MergeRequestApprovalSetting.count }.by(0)
            .and change { existing_setting.reload.allow_author_approval }.to(false)
        end

        it 'responds with a successful service response', :aggregate_failures do
          response = subject.execute

          expect(response).to be_success
          expect(response.payload.allow_author_approval).to be false
        end
      end

      context 'when saving fails' do
        let(:params) { { allow_author_approval: nil } }

        it 'responds with an error service response', :aggregate_failures do
          response = subject.execute

          expect(response).to be_error
          expect(response.message).to eq('Failed to update merge request approval settings')
          expect(response.payload).to contain_exactly('Allow author approval is not included in the list')
        end
      end
    end
  end
end

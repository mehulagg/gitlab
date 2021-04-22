# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Users::UpdateOpenIssueCountWorker do
  let_it_be(:current_user) { create(:user) }
  let_it_be(:second_user) { create(:user) }
  let_it_be(:third_user) { create(:user) }

  describe '#perform' do
    let(:current_user_id) { current_user.id }
    let(:target_user_ids) { [second_user.id, third_user.id] }

    subject { described_class.new.perform(current_user_id, target_user_ids) }

    context 'when arguments are missing' do
      context 'when current_user_id is missing' do
        let(:current_user_id) { nil }

        it 'raises an error' do
          expect { subject }.to raise_error(ArgumentError, /No current user ID provided/)
        end
      end

      context 'when target_user_ids are missing' do
        context 'when nil' do
          let(:target_user_ids) { nil }

          it 'raises an error' do
            expect { subject }.to raise_error(ArgumentError, /No target user ID provided/)
          end
        end

        context 'when empty array' do
          let(:target_user_ids) { [] }

          it 'raises an error' do
            expect { subject }.to raise_error(ArgumentError, /No target user ID provided/)
          end
        end

        context 'when not an ID' do
          let(:target_user_ids) { "nonsense" }

          it 'raises an error' do
            expect { subject }.to raise_error(ArgumentError, /No valid target user ID provided/)
          end
        end
      end
    end

    context 'when successful' do
      let(:fake_service1) { double }
      let(:fake_service2) { double }

      it 'calls the user update service' do
        expect(Users::UpdateAssignedOpenIssueCountService).to receive(:new).with(current_user: current_user, target_user: second_user).once.and_return(fake_service1)
        expect(Users::UpdateAssignedOpenIssueCountService).to receive(:new).with(current_user: current_user, target_user: third_user).once.and_return(fake_service2)
        expect(fake_service1).to receive(:execute)
        expect(fake_service2).to receive(:execute)

        subject
      end
    end
  end
end

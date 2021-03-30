# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Users::DeactivateDormantUsersWorker do
  describe '#perform' do
    subject(:worker) { described_class.new }

    context 'when automatic deactivation of dormant users is enabled' do
      before do
        stub_application_setting(deactivate_dormant_users: true)
      end

      it 'deactivates dormant users' do
        user_that_can_be_deactivated = spy(:user, can_be_deactivated?: true)
        user_that_can_not_be_deactivated = spy(:user, can_be_deactivated?: false)
        dormant_users = double

        expect(User).to receive(:dormant).and_return(dormant_users)
        expect(dormant_users).to receive(:find_each)
          .and_yield(user_that_can_be_deactivated)
          .and_yield(user_that_can_not_be_deactivated)

        worker.perform

        expect(user_that_can_be_deactivated).to have_received(:deactivate)
        expect(user_that_can_not_be_deactivated).not_to have_received(:deactivate)
      end
    end

    context 'when automatic deactivation of dormant users is disabled' do
      before do
        stub_application_setting(deactivate_dormant_users: false)
      end

      it 'deactivates dormant users' do
        expect(User).not_to receive(:dormant)

        worker.perform
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Users::DeactivateDormantUsersWorker do
  describe '#perform' do
    subject(:worker) { described_class.new }

    it 'does not run for GitLab.com' do
      allow(Gitlab).to receive(:com?).and_return(true)
      expect(Gitlab::CurrentSettings).not_to receive(:current_application_settings)
      expect(User).not_to receive(:dormant)

      worker.perform
    end

    context 'when automatic deactivation of dormant users is enabled' do
      before do
        stub_application_setting(deactivate_dormant_users: true)
      end

      it 'deactivates dormant users' do
        user_that_can_be_deactivated_1 = spy(:user, can_be_deactivated?: true)
        user_that_can_be_deactivated_2 = spy(:user, can_be_deactivated?: true)
        user_that_can_not_be_deactivated_1 = spy(:user, can_be_deactivated?: false)
        user_that_can_not_be_deactivated_2 = spy(:user, can_be_deactivated?: false)
        dormant_users = double
        users_with_no_activity = double

        expect(User).to receive(:dormant).and_return(dormant_users)
        expect(dormant_users).to receive(:find_each)
          .and_yield(user_that_can_be_deactivated_1)
          .and_yield(user_that_can_not_be_deactivated_1)

        expect(User).to receive(:with_no_activity).and_return(users_with_no_activity)
        expect(users_with_no_activity).to receive(:find_each)
          .and_yield(user_that_can_be_deactivated_2)
          .and_yield(user_that_can_not_be_deactivated_2)

        worker.perform

        expect(user_that_can_be_deactivated_1).to have_received(:deactivate)
        expect(user_that_can_not_be_deactivated_1).not_to have_received(:deactivate)
        expect(user_that_can_be_deactivated_2).to have_received(:deactivate)
        expect(user_that_can_not_be_deactivated_2).not_to have_received(:deactivate)
      end
    end

    context 'when automatic deactivation of dormant users is disabled' do
      before do
        stub_application_setting(deactivate_dormant_users: false)
      end

      it 'does nothing' do
        expect(User).not_to receive(:dormant)
        expect(User).not_to receive(:with_no_activity)

        worker.perform
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Users::AuthorizedBuildService do
  describe '#execute' do
    context 'with non admin user' do
      let(:non_admin) { create(:user) }

      context 'when user signup cap is set' do
        before do
          allow(Gitlab::CurrentSettings).to receive(:new_user_signups_cap).and_return(10)
        end

        it 'does not set the user state to blocked_pending_approval for non human users' do
          params = {
            name: 'Project Bot',
            email: 'project_bot@example.com',
            username: 'project_bot',
            user_type: 'project_bot'
          }

          service = described_class.new(non_admin, params)
          user = service.execute

          expect(user).to be_active
        end
      end
    end
  end
end

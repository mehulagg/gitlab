# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ResourceAccessTokens::CreateService do #rubocop:disable RSpec/FilePath
  subject { described_class.new(user, resource).execute }

  describe '#execute' do
    context 'with enforced group managed account enabled' do
      let(:group) { create(:group_with_managed_accounts, :private) }
      let(:resource) { create(:project, group: group)}
      let(:user) { create(:user, :group_managed, managing_group: group) }

      before do
        stub_feature_flags(group_managed_accounts: true)
        stub_licensed_features(group_saml: true)
        resource.add_maintainer(user)
      end

      it 'returns the error' do
        response = subject

        expect(response.error?).to be true
        expect(response.errors).to include("Failed to provide maintainer access")
      end

      it 'does not add the project bot as a member' do
        expect { subject }.not_to change { Member.count }
      end

      it 'does not create a project bot user', :sidekiq_inline do
        expect { subject }.not_to change { User.count }
      end
    end
  end
end

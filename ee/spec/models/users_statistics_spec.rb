# frozen_string_literal: true

require 'spec_helper'

RSpec.describe UsersStatistics do
  let(:users_statistics) { build(:users_statistics) }

  describe '#billable' do
    it 'sums users statistics values excluding blocked users and bots' do
      expect(users_statistics.billable).to eq(69)
    end

    context 'when there is an ultimate license' do
      before do
        license = create(:license, plan: License::ULTIMATE_PLAN)
        allow(License).to receive(:current).and_return(license)
      end

      it 'excludes blocked users, bots, guest users, and users without a group or project' do
        expect(users_statistics.billable).to eq(41)
      end
    end
  end
end

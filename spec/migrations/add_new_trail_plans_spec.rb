require 'spec_helper'

require_migration!

RSpec.describe AddNewTrailPlans, :migration do
  describe '#up' do
    before do
      allow(Gitlab).to receive(:dev_env_org_or_com?).and_return true
    end

    it 'creates 2 entries within the plans table' do
      expect { migrate! }.to change { AddNewTrailPlans::Plan.count }.by 2
      expect(AddNewTrailPlans::Plan.last(2).pluck(:name)).to match_array(['ultimate_trial', 'premium_trial'])
    end

    it 'creates 2 entries for plan limits' do
      expect { migrate! }.to change { AddNewTrailPlans::PlanLimits.count }.by 2
    end
  end

  describe '#down' do
    before do
      table(:plans).create!(name: 'random')
      allow(Gitlab).to receive(:dev_env_org_or_com?).and_return true

    end

    it 'removes the newly added ultimate and premium trial entries' do
      reversible_migration do |migration|
        migration.before -> {
          expect(AddNewTrailPlans::Plan.count).to eql(1)
          expect(AddNewTrailPlans::PlanLimits.count).to eql(0)
        }

        migration.after -> {
          expect(AddNewTrailPlans::Plan.count).to eql(3)
          expect(AddNewTrailPlans::PlanLimits.count).to eql(2)
        }
      end
    end
  end
end

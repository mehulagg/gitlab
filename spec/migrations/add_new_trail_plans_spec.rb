# frozen_string_literal: true

require 'spec_helper'

require_migration!

RSpec.describe AddNewTrailPlans, :migration do
  describe '#up' do
    before do
      allow(Gitlab).to receive(:dev_env_org_or_com?).and_return true
    end

    it 'creates 2 entries within the plans table' do
      expect { migrate! }.to change { AddNewTrailPlans::Plan.count }.by 2
      expect(AddNewTrailPlans::Plan.last(2).pluck(:name)).to match_array(%w(ultimate_trial premium_trial))
    end

    it 'creates 2 entries for plan limits' do
      expect { migrate! }.to change { AddNewTrailPlans::PlanLimits.count }.by 2
    end

    context 'when the plan limits for gold and silver exists' do
      before do
        table(:plans).create!(id: 1, name: 'gold', title: 'Gold')
        table(:plan_limits).create!(id: 1, plan_id: 1, storage_size_limit: 2000)
        table(:plans).create!(id: 2, name: 'silver', title: 'Silver')
        table(:plan_limits).create!(id: 2, plan_id: 2, storage_size_limit: 1000)
      end

      it 'duplicaes the gold and silvers plan limits entries' do
        migrate!

        ultimate_plan_limits = AddNewTrailPlans::Plan.find_by(name: 'ultimate_trial').limits
        expect(ultimate_plan_limits.storage_size_limit).to be 2000

        premium_plan_limits = AddNewTrailPlans::Plan.find_by(name: 'premium_trial').limits
        expect(premium_plan_limits.storage_size_limit).to be 1000
      end
    end

    context 'when the instance is not SaaS' do
      before do
        allow(Gitlab).to receive(:dev_env_org_or_com?).and_return false
      end

      it 'does not create plans and plan limits and returns' do
        expect { migrate! }.not_to change { AddNewTrailPlans::Plan.count }
        expect { migrate! }.not_to change { AddNewTrailPlans::Plan.count }
      end
    end
  end

  describe '#down' do
    context 'when the instance is SaaS' do
      before do
        table(:plans).create!(name: 'random')
        allow(Gitlab).to receive(:dev_env_org_or_com?).and_return true
      end

      it 'removes the newly added ultimate and premium trial entries' do
        reversible_migration do |migration|
          migration.before -> {
            expect(AddNewTrailPlans::Plan.count).to be(1)
            expect(AddNewTrailPlans::Plan.pluck(:name, :title)).to match_array(
              [['random', nil]]
            )
            expect(AddNewTrailPlans::PlanLimits.count).to be(0)
          }

          migration.after -> {
            expect(AddNewTrailPlans::Plan.pluck(:name, :title)).to match_array(
              [
                ['premium_trial', 'Premium Trial'],
                ['random', nil],
                ['ultimate_trial', 'Ultimate Trial']
              ]
            )
            expect(AddNewTrailPlans::PlanLimits.count).to be(2)
          }
        end
      end
    end

    context 'when the instance is not SaaS' do
      before do
        allow(Gitlab).to receive(:dev_env_org_or_com?).and_return false
        table(:plans).create!(id: 1, name: 'ultimate_trial', title: 'Ultimate Trial')
        table(:plans).create!(id: 2, name: 'premium_trial', title: 'Premium Trial')
        table(:plan_limits).create!(id: 1, plan_id: 1)
        table(:plan_limits).create!(id: 2, plan_id: 2)
      end

      it 'does not delete plans and plan limits and returns' do
        reversible_migration do |migration|
          migration.before -> {
            expect(AddNewTrailPlans::Plan.count).to be(2)
            expect(AddNewTrailPlans::PlanLimits.count).to be(2)
          }

          migration.after -> {
            expect(AddNewTrailPlans::Plan.count).to be(2)
            expect(AddNewTrailPlans::PlanLimits.count).to be(2)
          }
        end
      end
    end
  end
end

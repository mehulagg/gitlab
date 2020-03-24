# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Subscription::MaxSeatsUpdater do
  let(:user_1) { create(:user) }
  let(:user_2) { create(:user) }
  let(:group) { create(:group) }
  let(:project) { create(:project, namespace: group) }

  let!(:subscription) do
    create(:gitlab_subscription, namespace: group)
  end

  def update_max_seats_counter
    described_class.update(group)
  end

  before do
    allow(Gitlab::CurrentSettings).to receive(:should_check_namespace_plan?) { true }
  end

  context 'adding members for the first time' do
    it 'updates the max_seats_used counter' do
      group.add_developer(user_1)

      expect { update_max_seats_counter }
        .to change { subscription.reload.max_seats_used }.from(0).to(1)
    end
  end

  context 'adding more members' do
    before do
      group.add_developer(user_1)
      update_max_seats_counter
    end

    it 'updates the max_seats_used counter' do
      group.add_developer(user_2)

      expect { update_max_seats_counter }
        .to change { subscription.reload.max_seats_used }.from(1).to(2)
    end
  end

  context 'adding guest members' do
    context 'with a Gold plan' do
      it 'does not update the max_seats_used counter' do
        subscription.update_attribute(:hosted_plan, create(:gold_plan))
        group.add_guest(user_1)

        expect { update_max_seats_counter }
          .not_to change { subscription.reload.max_seats_used }
      end
    end

    context 'with the rest of plans' do
      [:bronze_plan, :silver_plan].each do |plan|
        it 'updates the max_seats_used counter' do
          subscription.update_attribute(:hosted_plan, create(plan))
          group.add_developer(user_1)

          expect { update_max_seats_counter }
            .to change { subscription.reload.max_seats_used }.from(0).to(1)
        end
      end
    end
  end

  context 'deleting members' do
    let!(:new_member) { group.add_developer(user_2) }

    before do
      group.add_owner(user_1)
      update_max_seats_counter
    end

    it 'does not update the max_seats_used counter' do
      expect(subscription.max_seats_used).to eq(2)

      expect { ::Members::DestroyService.new(user_1).execute(new_member) }
        .not_to change { subscription.max_seats_used }
    end
  end

  context 'with bad settings' do
    before do
      group.add_developer(user_1)
    end

    context 'when DB is read-only' do
      before do
        expect(Gitlab::Database).to receive(:read_only?) { true }
      end

      it 'skips the update' do
        expect { update_max_seats_counter }.not_to change { subscription.max_seats_used }
      end
    end

    context 'when feature is disabled' do
      before do
        stub_feature_flags(gitlab_com_max_seats_update: false)
      end

      it 'skips the update' do
        expect { update_max_seats_counter }.not_to change { subscription.max_seats_used }
      end
    end

    context 'when check of namespace plan is disabled' do
      before do
        allow(Gitlab::CurrentSettings).to receive(:should_check_namespace_plan?) { false }
      end

      it 'skips the update' do
        expect { update_max_seats_counter }.not_to change { subscription.max_seats_used }
      end
    end
  end
end

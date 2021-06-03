# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::SnapshotsFinder do
  let_it_be(:admin_user) { create(:user, :admin) }
  let_it_be(:enabled_namespace) { create(:devops_adoption_enabled_namespace) }
  let_it_be(:first_end_time) { (Time.zone.now - 1.year).end_of_month }
  let_it_be(:snapshot1) { create(:devops_adoption_snapshot, namespace_id: enabled_namespace.namespace_id, end_time: first_end_time) }
  let_it_be(:snapshot2) { create(:devops_adoption_snapshot, namespace_id: enabled_namespace.namespace_id, end_time: first_end_time + 2.months) }
  let_it_be(:snapshot3) { create(:devops_adoption_snapshot, namespace_id: enabled_namespace.namespace_id, end_time: first_end_time + 3.months) }

  subject(:finder) { described_class.new(admin_user, enabled_namespace, params: params) }

  let(:params) { {} }

  describe '#execute' do
    context 'with timespan provided' do
      let(:params) { { end_time_before: first_end_time + 2.months + 1.day, end_time_after: first_end_time + 1.day } }

      it 'returns snapshots in given timespan' do
        expect(finder.execute).to match_array([snapshot2])
      end
    end

    context 'without timespan provided' do
      it 'returns all snapshots' do
        expect(finder.execute).to match_array([snapshot1, snapshot2, snapshot3])
      end
    end
  end
end

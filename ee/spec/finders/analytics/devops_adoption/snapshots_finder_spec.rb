# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::SnapshotsFinder do
  let_it_be(:enabled_namespace) { create(:devops_adoption_enabled_namespace) }
  let_it_be(:first_end_time) { 1.year.ago.end_of_month }
  let_it_be(:snapshot1) { create(:devops_adoption_snapshot, namespace_id: enabled_namespace.namespace_id, end_time: first_end_time) }
  let_it_be(:snapshot2) do
    create(:devops_adoption_snapshot, namespace_id: enabled_namespace.namespace_id, end_time: 2.months.after(first_end_time).end_of_month)
  end

  let_it_be(:snapshot3) do
    create(:devops_adoption_snapshot, namespace_id: enabled_namespace.namespace_id, end_time: 3.months.after(first_end_time).end_of_month)
  end

  let(:finder) { described_class.new(params: params) }

  let(:params) { { namespace_id: enabled_namespace.namespace_id } }

  describe '#execute' do
    subject(:snapshots) { finder.execute }

    context 'with timespan provided' do
      before do
        params[:end_time_before] = 1.day.before(snapshot3.end_time)
        params[:end_time_after] = 1.day.after(first_end_time)
      end

      it 'returns snapshots in given timespan' do
        expect(snapshots).to match_array([snapshot2])
      end
    end

    context 'without timespan provided' do
      it 'returns all snapshots ordered by end_time' do
        expect(snapshots).to eq([snapshot3, snapshot2, snapshot1])
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::MergeRequests::LeadTime::AggregateService do
  let_it_be(:group) { create(:group) }
  let_it_be(:project, refind: true) { create(:project, :repository, group: group) }
  let_it_be(:developer) { create(:user) }
  let_it_be(:guest) { create(:user) }
  let(:container) { project }
  let(:actor) { developer }
  let(:service) { described_class.new(container: container, current_user: actor, params: params) }
  let(:request_time) { DateTime.new(2020, 5, 1) }
  let(:params) { { from: DateTime.new(2020, 4, 1), interval: "all" } }

  def make_mr(proj, created_at, merged_at)
    updated_at = merged_at || created_at
    create(:merge_request,
      :unique_branches,
      state: merged_at ? 'merged' : 'opened',
      created_at: created_at,
      updated_at: updated_at,
      source_project: proj,
      target_project: proj).metrics.tap do |metrics|
        # NOTE: MR::Metrics are created almost immediately after the MR itself,
        # however the merged_at is only updated later via a background task.
        metrics.update!(
          created_at: created_at,
          updated_at: merged_at || created_at,
          merged_at: merged_at
        )
      end
  end

  before_all do
    group.add_developer(developer)
    group.add_guest(guest)
  end

  before do
    stub_licensed_features(dora4_analytics: true)
  end

  around do |example|
    travel_to(request_time) { example.run }
  end

  describe '#execute' do
    subject { service.execute }

    before do
      make_mr(project, DateTime.new(2020, 4, 1), DateTime.new(2020, 4, 1))
      make_mr(project, DateTime.new(2020, 4, 1), DateTime.new(2020, 4, 2))
      make_mr(project, DateTime.new(2020, 4, 3), nil)
      make_mr(project, DateTime.new(2020, 4, 1), DateTime.new(2020, 4, 4))
      make_mr(project, DateTime.new(2020, 4, 1), DateTime.new(2020, 4, 5))
    end

    shared_examples_for 'validation error' do
      it 'returns an error with message' do
        result = subject

        expect(result[:status]).to eq(:error)
        expect(result[:message]).to eq(message)
      end
    end

    it 'returns lead times' do
      result = subject

      expect(result[:status]).to eq(:success)
      expect(result[:lead_times]).to eq(
        [
          {
            from: params[:from],
            to: request_time,
            value: 2880
          }
        ]
      )
    end

    context 'when date range is specified' do
      let(:params) { { from: DateTime.new(2020, 4, 1), to: DateTime.new(2020, 4, 4) } }

      it 'returns lead times' do
        result = subject

        expect(result[:status]).to eq(:success)
        expect(result[:lead_times]).to eq(
          [
            {
              from: params[:from],
              to: params[:to],
              value: 720
            }
          ]
        )
      end
    end

    context 'when the container is group' do
      let(:container) { create(:group) }

      it_behaves_like 'validation error' do
        let(:message) { 'Only project level aggregation is supported' }
      end
    end

    context 'when paramer is empty' do
      let(:params) { {} }

      it_behaves_like 'validation error' do
        let(:message) { 'Parameter `from` must be specified' }
      end
    end

    context 'when to is eariler than from' do
      let(:params) { { from: 3.days.ago.to_datetime, to: 4.days.ago.to_datetime } }

      it_behaves_like 'validation error' do
        let(:message) { 'Parameter `to` is before the `from` date' }
      end
    end

    context 'when the date range is too broad' do
      let(:params) { { from: 1.year.ago.to_datetime } }

      it_behaves_like 'validation error' do
        let(:message) { 'Date range is greater than 91 days' }
      end
    end

    context 'when the interval is not supported' do
      let(:params) { { from: 3.days.ago.to_datetime, interval: 'unknown' } }

      it_behaves_like 'validation error' do
        let(:message) { 'Parameter `interval` must be one of ("all", "monthly", "daily")' }
      end
    end

    context 'when the actor does not have permission to read DORA4 metrics' do
      let(:actor) { guest }

      it_behaves_like 'validation error' do
        let(:message) { 'You do not have permission to access lead times' }
      end
    end

    context 'when license is insufficient' do
      before do
        stub_licensed_features(dora4_analytics: false)
      end

      it_behaves_like 'validation error' do
        let(:message) { 'You do not have permission to access lead times' }
      end
    end
  end
end

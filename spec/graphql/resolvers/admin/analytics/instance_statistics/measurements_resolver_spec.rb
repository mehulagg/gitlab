# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Admin::Analytics::InstanceStatistics::MeasurementsResolver do
  include GraphqlHelpers

  let_it_be(:admin_user) { create(:user, :admin) }
  let(:current_user) { admin_user }

  describe '#resolve' do
    let_it_be(:user) { create(:user) }

    let_it_be(:project_measurement_new) { create(:instance_statistics_measurement, :project_count, recorded_at: 2.days.ago) }
    let_it_be(:project_measurement_old) { create(:instance_statistics_measurement, :project_count, recorded_at: 10.days.ago) }

    subject { resolve_measurements({ identifier: 'projects' }, { current_user: current_user }) }

    context 'when requesting project count measurements' do
      context 'as an admin user' do
        let(:current_user) { admin_user }

        it 'returns the records, latest first' do
          expect(subject).to eq([project_measurement_new, project_measurement_old])
        end
      end

      context 'as a non-admin user' do
        let(:current_user) { user }

        it 'raises ResourceNotAvailable error' do
          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'as an unauthenticated user' do
        let(:current_user) { nil }

        it 'raises ResourceNotAvailable error' do
          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end
    end

    context 'when requesting pipeline counts by pipeline status' do
      let_it_be(:pipelines_succeeded_measurement) { create(:instance_statistics_measurement, :pipelines_succeeded_count, recorded_at: 2.days.ago) }
      let_it_be(:pipelines_skipped_measurement) { create(:instance_statistics_measurement, :pipelines_skipped_count, recorded_at: 2.days.ago) }

      subject { resolve_measurements({ identifier: identifier }, { current_user: current_user }) }

      context 'filter for pipelines_succeeded' do
        let(:identifier) { 'pipelines_succeeded' }

        it { is_expected.to eq([pipelines_succeeded_measurement]) }
      end

      context 'filter for pipelines_skipped' do
        let(:identifier) { 'pipelines_skipped' }

        it { is_expected.to eq([pipelines_skipped_measurement]) }
      end

      context 'filter for pipelines_failed' do
        let(:identifier) { 'pipelines_failed' }

        it { is_expected.to be_empty }
      end

      context 'filter for pipelines_canceled' do
        let(:identifier) { 'pipelines_canceled' }

        it { is_expected.to be_empty }
      end
    end
  end

  def resolve_measurements(args = {}, context = {})
    resolve(described_class, args: args, ctx: context)
  end
end

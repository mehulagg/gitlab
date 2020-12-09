# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Ci::CodeCoverageSummaryResolver do
  include GraphqlHelpers

  describe '#resolve' do
    let_it_be(:current_user) { create(:user) }
    let_it_be(:project) { create(:project) }

    context 'when project has coverage' do
      let!(:coverage_1) { create(:ci_daily_build_group_report_result, project: project) }
      let!(:coverage_2) { create(:ci_daily_build_group_report_result, project: project, group_name: 'karma') }

      let(:expected_results) do
        {
          average_coverage: 77.0,
          coverage_count: 2,
          last_updated_on: Date.current
        }
      end

      it 'returns coverage summary for the project as a batch' do
        results = batch_sync do
          resolve_coverages
        end

        expect(results).to eq(expected_results)
      end
    end

    context 'when project does not have coverage' do
      it 'returns nil' do
        results = batch_sync do
          resolve_coverages
        end

        expect(results).to be_nil
      end
    end
  end

  def resolve_coverages(args = {}, context = { current_user: current_user })
    resolve(described_class, obj: project, args: args, ctx: context)
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::SecurityReportSummaryResolver do
  include GraphqlHelpers

  let_it_be(:pipeline) { double('project') }

  describe '#resolve' do
    context 'All fields are requested' do
      let(:lookahead) do
        build_mock_lookahead(expected_selection_info)
      end

      let(:expected_selection_info) do
        {
          dast: [:scanned_resources_count, :vulnerabilities_count],
          sast: [:scanned_resources_count, :vulnerabilities_count],
          container_scanning: [:scanned_resources_count, :vulnerabilities_count],
          dependency_scanning: [:scanned_resources_count, :vulnerabilities_count],
          coverage_fuzzing: [:scanned_resources_count, :vulnerabilities_count]
        }
      end

      it 'returns calls the ReportSummaryService' do
        expect_next_instance_of(
          Security::ReportSummaryService,
          pipeline,
          expected_selection_info
        ) do |summary_service|
          expect(summary_service).to receive(:execute)
        end

        resolve(described_class, obj: pipeline, args: { lookahead: lookahead })
      end
    end
  end
end

def build_mock_lookahead(structure)
  lookahead_selections = structure.map do |report_type, count_types|
    stub_count_types = count_types.map do |count_type|
      double(count_type, name: count_type)
    end
    double(report_type, name: report_type, selections: stub_count_types)
  end

  double('lookahead', selections: lookahead_selections)
end

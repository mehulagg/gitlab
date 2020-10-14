# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::CompareTestReportsService do
  let(:service) { described_class.new(project) }
  let(:project) { create(:project, :repository) }

  describe '#execute' do
    subject { service.execute(base_pipeline, head_pipeline) }

    context 'when head pipeline has test reports' do
      let!(:base_pipeline) { nil }
      let!(:head_pipeline) { create(:ci_pipeline, :with_test_reports, project: project) }

      it 'returns status and data' do
        expect(subject[:status]).to eq(:parsed)
        expect(subject[:data]).to match_schema('entities/test_reports_comparer')
      end
    end

    context 'when base and head pipelines have test reports' do
      let!(:base_pipeline) { create(:ci_pipeline, :with_test_reports, project: project) }
      let!(:head_pipeline) { create(:ci_pipeline, :with_test_reports, project: project) }

      it 'returns status and data' do
        expect(subject[:status]).to eq(:parsed)
        expect(subject[:data]).to match_schema('entities/test_reports_comparer')
      end
    end

    context 'when head pipeline has corrupted test reports' do
      let!(:base_pipeline) { nil }
      let!(:head_pipeline) { create(:ci_pipeline, project: project) }

      before do
        build = create(:ci_build, pipeline: head_pipeline, project: head_pipeline.project)
        create(:ci_job_artifact, :junit_with_corrupted_data, job: build, project: project)
      end

      it 'returns a parsed TestReports success status and failure on the individual suite' do
        expect(subject[:status]).to eq(:parsed)
        expect(subject.dig(:data, 'status')).to eq('success')
        expect(subject.dig(:data, 'suites', 0, 'status') ).to eq('error')
      end
    end

    context 'test failure history' do
      let!(:base_pipeline) { nil }
      let!(:head_pipeline) { create(:ci_pipeline, :with_test_reports, project: project) }

      let(:recent_failures) do
        subject.dig(:data, 'suites', 0, 'new_failures').map { |f| f['recent_failures'] }
      end

      # Create test case failure records based on the head pipeline build
      before do
        build = head_pipeline.builds.last
        build.update_column(:finished_at, 1.day.ago) # Just to be sure we are included in the report window

        # The JUnit fixture for the given build has 2 failures.
        # This service will create 1 test case failure record for each.
        Ci::TestCasesService.new.execute(build)
      end

      it 'loads on the report', :aggregate_failures do
        expect(subject[:data]).to match_schema('entities/test_reports_comparer')
        expect(recent_failures).to eq([
          { 'count' => 1, 'base_branch' => 'master' },
          { 'count' => 1, 'base_branch' => 'master' }
        ])
      end
    end
  end

  describe '#latest?' do
    subject { service.latest?(base_pipeline, head_pipeline, data) }

    let!(:base_pipeline) { nil }
    let!(:head_pipeline) { create(:ci_pipeline, :with_test_reports, project: project) }
    let!(:key) { service.send(:key, base_pipeline, head_pipeline) }

    context 'when cache key is latest' do
      let(:data) { { key: key } }

      it { is_expected.to be_truthy }
    end

    context 'when cache key is outdated' do
      before do
        head_pipeline.update_column(:updated_at, 10.minutes.ago)
      end

      let(:data) { { key: key } }

      it { is_expected.to be_falsy }
    end

    context 'when cache key is empty' do
      let(:data) { { key: nil } }

      it { is_expected.to be_falsy }
    end
  end
end

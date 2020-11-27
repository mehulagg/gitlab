# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::TestFailureHistoryService, :aggregate_failures do
  describe '#execute' do
    let(:project) { create(:project) }
    let(:pipeline) { create(:ci_empty_pipeline, status: :created, project: project) }

    subject(:execute_service) { described_class.new.execute(pipeline) }

    context 'when pipeline has failed builds with test reports' do
      before do
        # The test report has 2 test case failures
        create(:ci_build, :failed, :test_reports, pipeline: pipeline, project: project)
      end

      it 'creates test case failures records' do
        execute_service

        expect(Ci::TestCase.count).to eq(2)
        expect(Ci::TestCaseFailure.count).to eq(2)
      end

      context 'when feature flag for test failure history is disabled' do
        before do
          stub_feature_flags(test_failure_history: false)
        end

        it 'does not persist data' do
          execute_service

          expect(Ci::TestCase.count).to eq(0)
          expect(Ci::TestCaseFailure.count).to eq(0)
        end
      end

      context 'when pipeline is not for the default branch' do
        before do
          pipeline.update_column(:ref, 'new-feature')
        end

        it 'does not persist data' do
          execute_service

          expect(Ci::TestCase.count).to eq(0)
          expect(Ci::TestCaseFailure.count).to eq(0)
        end
      end

      context 'when test failure data have already been persisted with the same exact attributes' do
        before do
          execute_service
        end

        it 'does not fail but does not persist new data' do
          expect { described_class.new.execute(pipeline) }.not_to raise_error

          expect(Ci::TestCase.count).to eq(2)
          expect(Ci::TestCaseFailure.count).to eq(2)
        end
      end

      context 'when number of failed test cases exceed the limit' do
        before do
          stub_const("#{described_class.name}::MAX_TRACKABLE_FAILURES", 1)
        end

        it 'does not persist data' do
          execute_service

          expect(Ci::TestCase.count).to eq(0)
          expect(Ci::TestCaseFailure.count).to eq(0)
        end
      end

      context 'when number of failed test cases across multiple builds exceed the limit' do
        before do
          stub_const("#{described_class.name}::MAX_TRACKABLE_FAILURES", 2)

          # This other test report has 1 unique test case failure which brings us to 3 total failures across all builds
          # thus exceeding the limit of 2 for MAX_TRACKABLE_FAILURES
          create(:ci_build, :failed, :test_reports_with_duplicate_failed_test_names, pipeline: pipeline, project: project)
        end

        it 'does not persist data' do
          execute_service

          expect(Ci::TestCase.count).to eq(0)
          expect(Ci::TestCaseFailure.count).to eq(0)
        end
      end
    end

    context 'when test failure data have duplicates within the same payload (happens when the JUnit report has duplicate test case names but have different failures)' do
      before do
        # The test report has 2 test case failures but with the same test case keys
        create(:ci_build, :failed, :test_reports_with_duplicate_failed_test_names, pipeline: pipeline, project: project)
      end

      it 'does not fail but does not persist duplicate data' do
        expect { execute_service }.not_to raise_error

        expect(Ci::TestCase.count).to eq(1)
        expect(Ci::TestCaseFailure.count).to eq(1)
      end
    end

    context 'when pipeline has no failed builds with test reports' do
      before do
        create(:ci_build, :test_reports, pipeline: pipeline, project: project)
        create(:ci_build, :failed, pipeline: pipeline, project: project)
      end

      it 'does not persist data' do
        execute_service

        expect(Ci::TestCase.count).to eq(0)
        expect(Ci::TestCaseFailure.count).to eq(0)
      end
    end
  end
end

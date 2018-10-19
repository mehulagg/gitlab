require 'spec_helper'

describe Ci::Pipeline do
  let(:user) { create(:user) }
  set(:project) { create(:project) }

  let(:pipeline) do
    create(:ci_empty_pipeline, status: :created, project: project)
  end

  it { is_expected.to have_one(:chat_data) }
  it { is_expected.to have_many(:job_artifacts).through(:builds) }

  describe '.failure_reasons' do
    it 'contains failure reasons about exceeded limits' do
      expect(described_class.failure_reasons)
        .to include 'activity_limit_exceeded', 'size_limit_exceeded'
    end
  end

  PIPELINE_ARTIFACTS_METHODS = [
    { method: :performance_artifact, options: [Ci::Build::PERFORMANCE_FILE, 'performance'] },
    { method: :license_management_artifact, options: [Ci::Build::LICENSE_MANAGEMENT_FILE, 'license_management'] }
  ].freeze

  PIPELINE_ARTIFACTS_METHODS.each do |method_test|
    method, options = method_test.values_at(:method, :options)
    describe method.to_s do
      context 'has corresponding job' do
        let!(:build) do
          filename, name = options

          create(
            :ci_build,
            :artifacts,
            name: name,
            pipeline: pipeline,
            options: {
              artifacts: {
                paths: [filename]
              }
            }
          )
        end

        it { expect(pipeline.send(method)).to eq(build) }
      end

      context 'no corresponding job' do
        before do
          create(:ci_build, pipeline: pipeline)
        end

        it { expect(pipeline.send(method)).to be_nil }
      end
    end
  end

  %w(performance license_management).each do |type|
    method = "has_#{type}_data?"

    describe "##{method}" do
      let(:artifact) { double(success?: true) }

      before do
        allow(pipeline).to receive(:"#{type}_artifact").and_return(artifact)
      end

      it { expect(pipeline.send(method.to_sym)).to be_truthy }
    end
  end

  %w(performance license_management).each do |type|
    method = "expose_#{type}_data?"

    describe "##{method}" do
      before do
        allow(pipeline).to receive(:"has_#{type}_data?").and_return(true)
        allow(pipeline.project).to receive(:feature_available?).and_return(true)
      end

      it { expect(pipeline.send(method.to_sym)).to be_truthy }
    end
  end

  describe '#with_security_reports scope' do
    let(:pipeline_1) { create(:ci_pipeline_without_jobs, project: project) }
    let(:pipeline_2) { create(:ci_pipeline_without_jobs, project: project) }
    let(:pipeline_3) { create(:ci_pipeline_without_jobs, project: project) }
    let(:pipeline_4) { create(:ci_pipeline_without_jobs, project: project) }
    let(:pipeline_5) { create(:ci_pipeline_without_jobs, project: project) }

    before do
      create(
        :ci_build,
        :success,
        :artifacts,
        name: 'sast',
        pipeline: pipeline_1,
        options: {
          artifacts: {
            paths: [Ci::JobArtifact::DEFAULT_FILE_NAMES[:sast]]
          }
        }
      )
      create(
        :ci_build,
        :success,
        :artifacts,
        name: 'dependency_scanning',
        pipeline: pipeline_2,
        options: {
          artifacts: {
            paths: [Ci::JobArtifact::DEFAULT_FILE_NAMES[:dependency_scanning]]
          }
        }
      )
      create(
        :ci_build,
        :success,
        :artifacts,
        name: 'container_scanning',
        pipeline: pipeline_3,
        options: {
          artifacts: {
            paths: [Ci::JobArtifact::DEFAULT_FILE_NAMES[:container_scanning]]
          }
        }
      )
      create(
        :ci_build,
        :success,
        :artifacts,
        name: 'dast',
        pipeline: pipeline_4,
        options: {
          artifacts: {
            paths: [Ci::JobArtifact::DEFAULT_FILE_NAMES[:dast]]
          }
        }
      )
      create(
        :ci_build,
        :success,
        :artifacts,
        name: 'foobar',
        pipeline: pipeline_5
      )
    end

    it "returns pipeline with security reports" do
      expect(described_class.with_security_reports).to eq([pipeline_1, pipeline_2, pipeline_3, pipeline_4])
    end
  end

  describe '#report_artifact_for_file_type' do
    let(:file_type) { :codequality }
    let!(:build) { create(:ci_build, pipeline: pipeline) }
    let!(:artifact) { create(:ci_job_artifact, :codequality, job: build) }

    subject { pipeline.report_artifact_for_file_type(file_type) }

    it 'returns the artifact' do
      expect(subject).to eq(artifact)
    end
  end

  describe '#legacy_report_artifact_for_file_type' do
    let(:file_type) { :codequality }
    let(:build_name) { ::EE::Ci::Pipeline::LEGACY_REPORT_FORMATS[file_type][:names].first }
    let(:artifact_path) { ::EE::Ci::Pipeline::LEGACY_REPORT_FORMATS[file_type][:files].first }

    let!(:build) do
      create(
        :ci_build,
        :success,
        :artifacts,
        name: build_name,
        pipeline: pipeline,
        options: {
          artifacts: {
            paths: [artifact_path]
          }
        }
      )
    end

    subject { pipeline.legacy_report_artifact_for_file_type(:codequality) }

    it 'returns the artifact' do
      expect(subject).to eq(OpenStruct.new(build: build, path: artifact_path))
    end
  end

  context 'performance' do
    def create_build(job_name, filename)
      create(
        :ci_build,
        :artifacts,
        name: job_name,
        pipeline: pipeline,
        options: {
          artifacts: {
            paths: [filename]
          }
        }
      )
    end

    it 'does not perform extra queries when calling pipeline artifacts methods after the first' do
      create_build('performance', 'performance.json')
      create_build('license_management', 'gl-license-management-report.json')

      pipeline.performance_artifact

      expect { pipeline.license_management_artifact }.not_to exceed_query_limit(0)
    end
  end
end

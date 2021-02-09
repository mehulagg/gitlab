# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Build::Context::Build do
  let(:pipeline)        { create(:ci_pipeline) }
  let(:seed_attributes) { { 'name' => 'some-job' } }

  let(:context) { described_class.new(pipeline, seed_attributes) }

  describe '#variables' do
    subject { context.variables }

    it { is_expected.to include('CI_COMMIT_REF_NAME' => 'master') }
    it { is_expected.to include('CI_PIPELINE_IID'    => pipeline.iid.to_s) }
    it { is_expected.to include('CI_PROJECT_PATH'    => pipeline.project.full_path) }
    it { is_expected.to include('CI_JOB_NAME'        => 'some-job') }
    it { is_expected.to include('CI_BUILD_REF_NAME'  => 'master') }

    context 'without passed build-specific attributes' do
      let(:context) { described_class.new(pipeline) }

      it { is_expected.to include('CI_JOB_NAME'       => nil) }
      it { is_expected.to include('CI_BUILD_REF_NAME' => 'master') }
      it { is_expected.to include('CI_PROJECT_PATH'   => pipeline.project.full_path) }
    end
  end

  describe '#variables_collection' do
    subject { context.variables_collection.map(&:to_runner_variable) }

    it { is_expected.to include(include(key: 'CI_COMMIT_REF_NAME', value: 'master')) }
    it { is_expected.to include(include(key: 'CI_PIPELINE_IID', value: pipeline.iid.to_s)) }
    it { is_expected.to include(include(key: 'CI_PROJECT_PATH', value: pipeline.project.full_path)) }
    it { is_expected.to include(include(key: 'CI_JOB_NAME', value: 'some-job')) }
    it { is_expected.to include(include(key: 'CI_BUILD_REF_NAME', value: 'master')) }

    context 'without passed build-specific attributes' do
      let(:context) { described_class.new(pipeline) }

      it { is_expected.to include(include(key: 'CI_JOB_NAME', value: nil)) }
      it { is_expected.to include(include(key: 'CI_BUILD_REF_NAME', value: 'master')) }
      it { is_expected.to include(include(key: 'CI_PROJECT_PATH', value: pipeline.project.full_path)) }
    end
  end
end

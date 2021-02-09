# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Build::Context::Global do
  let(:pipeline)       { create(:ci_pipeline) }
  let(:yaml_variables) { {} }

  let(:context) { described_class.new(pipeline, yaml_variables: yaml_variables) }

  describe '#variables' do
    subject { context.variables }

    it { is_expected.to include('CI_COMMIT_REF_NAME' => 'master') }
    it { is_expected.to include('CI_PIPELINE_IID'    => pipeline.iid.to_s) }
    it { is_expected.to include('CI_PROJECT_PATH'    => pipeline.project.full_path) }

    it { is_expected.not_to have_key('CI_JOB_NAME') }
    it { is_expected.not_to have_key('CI_BUILD_REF_NAME') }

    context 'with passed yaml variables' do
      let(:yaml_variables) { [{ key: 'SUPPORTED', value: 'parsed', public: true }] }

      it { is_expected.to include('SUPPORTED' => 'parsed') }
    end
  end

  describe '#variables_collection' do
    subject { context.variables_collection.map(&:to_runner_variable) }

    it { is_expected.to include({ key: 'CI_COMMIT_REF_NAME', value: 'master', protected: false, masked: false, public: true }) }
    it { is_expected.to include({ key: 'CI_PIPELINE_IID', value: pipeline.iid.to_s, protected: false, masked: false, public: true }) }
    it { is_expected.to include({ key: 'CI_PROJECT_PATH', value: pipeline.project.full_path, protected: false, masked: false, public: true }) }

    it { is_expected.not_to include(include(key: 'CI_JOB_NAME')) }
    it { is_expected.not_to include(include(key: 'CI_BUILD_REF_NAME')) }

    context 'with passed yaml variables' do
      let(:yaml_variables) { [{ key: 'SUPPORTED', value: 'parsed', public: true }] }

      it { is_expected.to include({ key: 'SUPPORTED', value: 'parsed', protected: false, masked: false, public: true }) }
    end
  end
end

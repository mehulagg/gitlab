# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Gitlab::Ci::Pipeline::Chain::Config::Content do
  let(:project) { create(:project, ci_config_path: ci_config_path) }
  let(:pipeline) { build(:ci_pipeline, project: project) }
  let(:content) { nil }
  let(:source) { :push }
  let(:command) { Gitlab::Ci::Pipeline::Chain::Command.new(project: project, content: content, source: source) }

  subject { described_class.new(pipeline, command) }

  context 'when project has compliance pipeline configuration defined' do
    let(:ci_config_path) { nil }
    let(:compliance_group) { create(:group, :private, name: "compliance") }
    let(:compliance_project) { create(:project, namespace: compliance_group, name: "hippa") }

    let(:framework) { create(:compliance_framework, namespace_id: compliance_group.id, pipeline_configuration_full_path: ".compliance-gitlab-ci.yml@compliance/hippa") }
    let!(:framework_project_setting) { create(:compliance_framework_project_setting, project: project, framework_id: framework.id) }

    let(:content_result) do
      <<~EOY
          ---
          include:
          - project: compliance/hippa
            file: ".compliance-gitlab-ci.yml"
      EOY
    end

    it 'includes compliance pipeline configuration content' do
      subject.perform!

      expect(pipeline.config_source).to eq 'external_project_source'
      expect(pipeline.pipeline_config.content).to eq(content_result)
      expect(command.config_content).to eq(content_result)
    end
  end
end

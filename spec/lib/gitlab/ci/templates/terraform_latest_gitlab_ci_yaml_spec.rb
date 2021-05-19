# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Terraform.latest.gitlab-ci.yml' do
  before do
    allow(Gitlab::Template::GitlabCiYmlTemplate).to receive(:excluded_patterns).and_return([])
  end

  subject(:template) { Gitlab::Template::GitlabCiYmlTemplate.find('Terraform.latest') }

  where(:default_branch) do
    %w[master main]
  end

  with_them do
    describe 'the created pipeline' do
      let(:pipeline_branch) { default_branch }
      let(:project) { create(:project, :custom_repo, files: { 'README.md' => '' }) }
      let(:user) { project.owner }
      let(:service) { Ci::CreatePipelineService.new(project, user, ref: pipeline_branch ) }
      let(:pipeline) { service.execute!(:push) }
      let(:build_names) { pipeline.builds.pluck(:name) }

      before do
        stub_application_setting(default_branch_name: default_branch)
        stub_ci_pipeline_yaml_file(template.content)
        allow_next_instance_of(Ci::BuildScheduleWorker).to receive(:perform).and_return(true)
      end

      context 'on the default branch' do
        it 'creates init, validate and build jobs' do
          expect(build_names).to include('init', 'validate', 'build', 'deploy')
        end
      end

      context 'outside of default branch' do
        let(:pipeline_branch) { 'patch-1' }

        before do
          project.repository.create_branch(pipeline_branch)
        end

        it 'does not creates a deploy and a test job' do
          expect(build_names).not_to include('deploy')
        end
      end
    end
  end
end

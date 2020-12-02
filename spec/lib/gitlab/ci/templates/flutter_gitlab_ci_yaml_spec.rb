# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Flutter.gitlab-ci.yml' do
  before do
    allow(Gitlab::Template::GitlabCiYmlTemplate).to receive(:excluded_patterns).and_return([])
  end

  subject(:template) { Gitlab::Template::GitlabCiYmlTemplate.find('Flutter') }

  describe 'the created pipeline' do
    let_it_be(:user) { create(:admin) }

    let(:default_branch) { 'master' }
    let(:pipeline_branch) { default_branch }
    let(:project) { create(:project, :custom_repo, files: { 'README.md' => '' }) }
    let(:service) { Ci::CreatePipelineService.new(project, user, ref: pipeline_branch ) }
    let(:pipeline) { service.execute!(:push) }
    let(:build_names) { pipeline.builds.pluck(:name) }

    before do
      stub_ci_pipeline_yaml_file(template.content)
      allow_any_instance_of(Ci::BuildScheduleWorker).to receive(:perform).and_return(true)
      allow(project).to receive(:default_branch).and_return(default_branch)
    end

    context 'on master branch' do
      it 'creates test, code_quality, build, deploy jobs' do
        expect(build_names).to include('test', 'code_quality')
      end
    end

    # context 'outside the master branch' do
    #   let(:pipeline_branch) { 'patch-1' }

    #   before do
    #     project.repository.create_branch(pipeline_branch)
    #   end

    #   it 'does not creates a deploy and a test job' do
    #     expect(build_names).not_to include('deploy')
    #   end
    # end
  end
end

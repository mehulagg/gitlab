# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'ThemeKit.gitlab-ci.yml' do
  before do
    allow(Gitlab::Template::GitlabCiYmlTemplate).to receive(:excluded_patterns).and_return([])
  end

  subject(:template) { Gitlab::Template::GitlabCiYmlTemplate.find('ThemeKit') }

  describe 'the created pipeline' do
    let(:default_branch) { 'master' }
    let(:pipeline_branch) { default_branch }
    let(:project) { create(:project, :custom_repo, files: { 'README.md' => '' }) }
    let(:user) { project.owner }
    let(:service) { Ci::CreatePipelineService.new(project, user, ref: pipeline_branch ) }
    let(:pipeline) { service.execute!(:push) }
    let(:build_names) { pipeline.builds.pluck(:name) }

    before do
      stub_ci_pipeline_yaml_file(template.content)
    end

    context 'on master branch' do
      it 'creates staging deploy' do
        expect(build_names).to include('staging')
      end
      it 'does not create production deploy' do
        expect(build_names).not_to include('production')
      end
    end

    context 'on tags branch' do
      let(:pipeline_branch) { 'tags' }

      before do
        project.repository.create_branch(pipeline_branch)
      end

      it 'does not creates a staging deploy' do
        expect(build_names).not_to include('deploy')
      end
      it 'only creates a production deploy' do
        expect(build_names).to include('production')
      end
    end
  end
end

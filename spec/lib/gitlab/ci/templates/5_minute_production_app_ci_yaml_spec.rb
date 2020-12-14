# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '5-Minute-Production-App.gitlab-ci.yml' do
  subject(:template) { Gitlab::Template::GitlabCiYmlTemplate.find('5-Minute-Production-App') }

  describe 'the created pipeline' do
    let_it_be(:user) { create(:admin) }

    let(:default_branch) { 'master' }
    let(:pipeline_branch) { default_branch }
    let(:project) { create(:project, :auto_devops, :custom_repo, files: { 'README.md' => '' }) }
    let(:service) { Ci::CreatePipelineService.new(project, user, ref: pipeline_branch ) }
    let(:pipeline) { service.execute!(:push) }
    let(:build_names) { pipeline.builds.pluck(:name) }

    before do
      stub_ci_pipeline_yaml_file(template.content)
    end

    it 'creates only build job' do
      expect(build_names).to match_array('build')
    end

    context 'when AWS variables are set' do
      before do
        create(:ci_variable, project: project, key: 'AWS_ACCESS_KEY_ID', value: 'AKIAIOSFODNN7EXAMPLE')
        create(:ci_variable, project: project, key: 'AWS_SECRET_ACCESS_KEY', value: 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY')
        create(:ci_variable, project: project, key: 'AWS_DEFAULT_REGION', value: 'us-west-2')
      end

      context 'when CERT_EMAIL is set' do
        before do
          create(:ci_variable, project: project, key: 'CERT_EMAIL', value: 'admin@example.com')
        end

        it 'creates all jobs' do
          expect(build_names).to match_array(%w(build terraform_apply deploy terraform_destroy))
        end

        context 'pipeline branch is protected' do
          before do
            create(:protected_branch, project: project, name: pipeline_branch)
          end

          it 'does not create a destroy job' do
            expect(build_names).to match_array(%w(build terraform_apply deploy))
          end
        end
      end

      context 'when CERT_EMAIL is missing' do
        it 'creates build and destroy jobs' do
          expect(build_names).to match_array(%w(build terraform_destroy))
        end
      end
    end
  end
end

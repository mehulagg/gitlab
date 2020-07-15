# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Auto-DevOps.gitlab-ci.yml' do
  subject(:template) { Gitlab::Template::GitlabCiYmlTemplate.find('Auto-DevOps') }

  describe 'the created pipeline' do
    let(:user) { create(:admin) }
    let(:default_branch) { 'master' }
    let(:pipeline_branch) { default_branch }
    let(:project) { create(:project, :auto_devops, :custom_repo, files: { 'README.md' => '' }) }
    let(:service) { Ci::CreatePipelineService.new(project, user, ref: pipeline_branch ) }
    let(:pipeline) { service.execute!(:push) }
    let(:build_names) { pipeline.builds.pluck(:name) }

    before do
      stub_ci_pipeline_yaml_file(template.content)
      allow_any_instance_of(Ci::BuildScheduleWorker).to receive(:perform).and_return(true)
      allow(project).to receive(:default_branch).and_return(default_branch)
    end

    shared_examples 'no Kubernetes deployment job' do
      it 'does not create any Kubernetes deployment-related builds' do
        expect(build_names).not_to include('production')
        expect(build_names).not_to include('production_manual')
        expect(build_names).not_to include('staging')
        expect(build_names).not_to include('canary')
        expect(build_names).not_to include('review')
        expect(build_names).not_to include(a_string_matching(/rollout \d+%/))
      end
    end

    it 'creates a build and a test job' do
      expect(build_names).to include('build', 'test')
    end

    context 'when the project is set for deployment to AWS' do
      let(:platform_value) { 'ECS' }
      let(:review_prod_build_names) { build_names.select {|n| n.include?('review') || n.include?('production')} }

      before do
        create(:ci_variable, project: project, key: 'AUTO_DEVOPS_PLATFORM_TARGET', value: platform_value)
      end

      shared_examples 'no ECS job when AUTO_DEVOPS_PLATFORM_TARGET is not present' do |job_name|
        context 'when AUTO_DEVOPS_PLATFORM_TARGET is nil' do
          let(:platform_value) { nil }

          it 'does not trigger the job' do
            expect(build_names).not_to include(job_name)
          end
        end

        context 'when AUTO_DEVOPS_PLATFORM_TARGET is empty' do
          let(:platform_value) { '' }

          it 'does not trigger the job' do
            expect(build_names).not_to include(job_name)
          end
        end
      end

      it_behaves_like 'no Kubernetes deployment job'

      it_behaves_like 'no ECS job when AUTO_DEVOPS_PLATFORM_TARGET is not present' do
        let(:job_name) { 'production_ecs' }
      end

      it 'creates an ECS deployment job for production only' do
        expect(review_prod_build_names).to contain_exactly('production_ecs')
      end

      context 'with FARGATE as a launch type' do
        let(:platform_value) { 'FARGATE' }

        it 'creates a FARGATE deployment job for production only' do
          expect(review_prod_build_names).to contain_exactly('production_fargate')
        end
      end

      context 'and we are not on the default branch' do
        let(:platform_value) { 'ECS' }
        let(:pipeline_branch) { 'patch-1' }

        before do
          project.repository.create_branch(pipeline_branch)
        end

        %w(review_ecs review_fargate).each do |job|
          it_behaves_like 'no ECS job when AUTO_DEVOPS_PLATFORM_TARGET is not present' do
            let(:job_name) { job }
          end
        end

        it 'creates an ECS deployment job for review only' do
          expect(review_prod_build_names).to contain_exactly('review_ecs')
        end

        context 'with FARGATE as a launch type' do
          let(:platform_value) { 'FARGATE' }

          it 'creates an FARGATE deployment job for review only' do
            expect(review_prod_build_names).to contain_exactly('review_fargate')
          end
        end
      end

      context 'and when the project has an active cluster' do
        let(:cluster) { create(:cluster, :project, :provided_by_gcp, projects: [project]) }

        before do
          allow(cluster).to receive(:active?).and_return(true)
        end

        context 'on default branch' do
          it 'triggers the deployment to Kubernetes, not to ECS' do
            expect(build_names).not_to include('review')
            expect(build_names).to include('production')
            expect(build_names).not_to include('production_ecs')
            expect(build_names).not_to include('review_ecs')
          end
        end
      end
    end

    context 'when the project has no active cluster' do
      it 'only creates a build and a test stage' do
        expect(pipeline.stages_names).to eq(%w(build test))
      end

      it_behaves_like 'no Kubernetes deployment job'
    end

    context 'when the project has an active cluster' do
      let!(:cluster) { create(:cluster, :project, :provided_by_gcp, projects: [project]) }

      describe 'deployment-related builds' do
        context 'on default branch' do
          it 'does not include rollout jobs besides production' do
            expect(build_names).to include('production')
            expect(build_names).not_to include('production_manual')
            expect(build_names).not_to include('staging')
            expect(build_names).not_to include('canary')
            expect(build_names).not_to include('review')
            expect(build_names).not_to include(a_string_matching(/rollout \d+%/))
          end

          context 'when STAGING_ENABLED=1' do
            before do
              create(:ci_variable, project: project, key: 'STAGING_ENABLED', value: '1')
            end

            it 'includes a staging job and a production_manual job' do
              expect(build_names).not_to include('production')
              expect(build_names).to include('production_manual')
              expect(build_names).to include('staging')
              expect(build_names).not_to include('canary')
              expect(build_names).not_to include('review')
              expect(build_names).not_to include(a_string_matching(/rollout \d+%/))
            end
          end

          context 'when CANARY_ENABLED=1' do
            before do
              create(:ci_variable, project: project, key: 'CANARY_ENABLED', value: '1')
            end

            it 'includes a canary job and a production_manual job' do
              expect(build_names).not_to include('production')
              expect(build_names).to include('production_manual')
              expect(build_names).not_to include('staging')
              expect(build_names).to include('canary')
              expect(build_names).not_to include('review')
              expect(build_names).not_to include(a_string_matching(/rollout \d+%/))
            end
          end
        end

        context 'outside of default branch' do
          let(:pipeline_branch) { 'patch-1' }

          before do
            project.repository.create_branch(pipeline_branch)
          end

          it 'does not include rollout jobs besides review' do
            expect(build_names).not_to include('production')
            expect(build_names).not_to include('production_manual')
            expect(build_names).not_to include('staging')
            expect(build_names).not_to include('canary')
            expect(build_names).to include('review')
            expect(build_names).not_to include(a_string_matching(/rollout \d+%/))
          end
        end
      end
    end
  end

  describe 'build-pack detection' do
    using RSpec::Parameterized::TableSyntax

    where(:case_name, :files, :variables, :include_build_names, :not_include_build_names) do
      'No match'        | { 'README.md' => '' }                   | {}                                          | %w()           | %w(build test)
      'Buildpack'       | { 'README.md' => '' }                   | { 'BUILDPACK_URL' => 'http://example.com' } | %w(build test) | %w()
      'Explicit set'    | { 'README.md' => '' }                   | { 'AUTO_DEVOPS_EXPLICITLY_ENABLED' => '1' } | %w(build test) | %w()
      'Explicit unset'  | { 'README.md' => '' }                   | { 'AUTO_DEVOPS_EXPLICITLY_ENABLED' => '0' } | %w()           | %w(build test)
      'DOCKERFILE_PATH' | { 'README.md' => '' }                   | { 'DOCKERFILE_PATH' => 'Docker.file' }      | %w(build test) | %w()
      'Dockerfile'      | { 'Dockerfile' => '' }                  | {}                                          | %w(build test) | %w()
      'Clojure'         | { 'project.clj' => '' }                 | {}                                          | %w(build test) | %w()
      'Go modules'      | { 'go.mod' => '' }                      | {}                                          | %w(build test) | %w()
      'Go gb'           | { 'src/gitlab.com/gopackage.go' => '' } | {}                                          | %w(build test) | %w()
      'Gradle'          | { 'gradlew' => '' }                     | {}                                          | %w(build test) | %w()
      'Java'            | { 'pom.xml' => '' }                     | {}                                          | %w(build test) | %w()
      'Multi-buildpack' | { '.buildpacks' => '' }                 | {}                                          | %w(build test) | %w()
      'NodeJS'          | { 'package.json' => '' }                | {}                                          | %w(build test) | %w()
      'PHP'             | { 'composer.json' => '' }               | {}                                          | %w(build test) | %w()
      'Play'            | { 'conf/application.conf' => '' }       | {}                                          | %w(build test) | %w()
      'Python'          | { 'Pipfile' => '' }                     | {}                                          | %w(build test) | %w()
      'Ruby'            | { 'Gemfile' => '' }                     | {}                                          | %w(build test) | %w()
      'Scala'           | { 'build.sbt' => '' }                   | {}                                          | %w(build test) | %w()
      'Static'          | { '.static' => '' }                     | {}                                          | %w(build test) | %w()
    end

    with_them do
      let(:user) { create(:admin) }
      let(:project) { create(:project, :custom_repo, files: files) }
      let(:service) { Ci::CreatePipelineService.new(project, user, ref: 'master' ) }
      let(:pipeline) { service.execute(:push) }
      let(:build_names) { pipeline.builds.pluck(:name) }

      before do
        stub_ci_pipeline_yaml_file(template.content)
        allow_any_instance_of(Ci::BuildScheduleWorker).to receive(:perform).and_return(true)
        variables.each do |(key, value)|
          create(:ci_variable, project: project, key: key, value: value)
        end
      end

      it 'creates a pipeline with the expected jobs' do
        expect(build_names).to include(*include_build_names)
        expect(build_names).not_to include(*not_include_build_names)
      end
    end
  end
end

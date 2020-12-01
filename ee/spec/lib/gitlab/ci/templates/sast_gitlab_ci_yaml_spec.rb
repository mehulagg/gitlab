# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'SAST.gitlab-ci.yml' do
  subject(:template) { Gitlab::Template::GitlabCiYmlTemplate.find('SAST') }

  describe 'the created pipeline' do
    let(:user) { create(:admin) }
    let(:default_branch) { 'master' }
    let(:files) { { 'README.txt' => '' } }
    let(:project) { create(:project, :custom_repo, files: files) }
    let(:service) { Ci::CreatePipelineService.new(project, user, ref: 'master' ) }
    let(:pipeline) { service.execute!(:push) }
    let(:build_names) { pipeline.builds.pluck(:name) }

    before do
      stub_ci_pipeline_yaml_file(template.content)
      allow_any_instance_of(Ci::BuildScheduleWorker).to receive(:perform).and_return(true)
      allow(project).to receive(:default_branch).and_return(default_branch)
    end

    context 'when project has no license' do
      context 'when SAST_DISABLED=1' do
        before do
          create(:ci_variable, project: project, key: 'SAST_DISABLED', value: '1')
        end

        it 'includes no jobs' do
          expect { pipeline }.to raise_error(Ci::CreatePipelineService::CreateError)
        end
      end

      context 'when SAST_EXPERIMENTAL_FEATURES is disabled for iOS projects' do
        let(:files) { { 'a.xcodeproj/x.pbxproj' => '' } }

        before do
          create(:ci_variable, project: project, key: 'SAST_EXPERIMENTAL_FEATURES', value: 'false')
        end

        it 'includes no jobs' do
          expect { pipeline }.to raise_error(Ci::CreatePipelineService::CreateError)
        end
      end

      context 'by default' do
        describe 'language detection' do
          using RSpec::Parameterized::TableSyntax

          where(:case_name, :files, :variables, :include_build_names) do
            'Android'              | { 'AndroidManifest.xml' => '', 'a.java' => '' } | { 'SAST_EXPERIMENTAL_FEATURES' => 'true' } | %w(mobsf-android-sast)
            'Android'              | { 'app/src/main/AndroidManifest.xml' => '' }    | { 'SAST_EXPERIMENTAL_FEATURES' => 'true' } | %w(mobsf-android-sast)
            'Android'              | { 'a/b/AndroidManifest.xml' => '' }             | { 'SAST_EXPERIMENTAL_FEATURES' => 'true' } | %w(mobsf-android-sast)
            'Apex'                 | { 'app.cls' => '' }                             | {}                                         | %w(pmd-apex-sast)
            'C'                    | { 'app.c' => '' }                               | {}                                         | %w(flawfinder-sast)
            'C++'                  | { 'app.cpp' => '' }                             | {}                                         | %w(flawfinder-sast)
            'C#'                   | { 'app.csproj' => '' }                          | {}                                         | %w(security-code-scan-sast)
            'Elixir'               | { 'mix.exs' => '' }                             | {}                                         | %w(sobelow-sast)
            'Golang'               | { 'main.go' => '' }                             | {}                                         | %w(gosec-sast)
            'Groovy'               | { 'app.groovy' => '' }                          | {}                                         | %w(spotbugs-sast)
            'iOS'                  | { 'a.xcodeproj/x.pbxproj' => '' }               | { 'SAST_EXPERIMENTAL_FEATURES' => 'true' } | %w(mobsf-ios-sast)
            'Java'                 | { 'app.java' => '' }                            | {}                                         | %w(spotbugs-sast)
            'Java with MobSF'      | { 'app.java' => '' }                            | { 'SAST_EXPERIMENTAL_FEATURES' => 'true' } | %w(spotbugs-sast)
            'Java without MobSF'   | { 'AndroidManifest.xml' => '', 'a.java' => '' } | {}                                         | %w(spotbugs-sast)
            'Javascript'           | { 'app.js' => '' }                              | {}                                         | %w(eslint-sast)
            'JSX'                  | { 'app.jsx' => '' }                             | {}                                         | %w(eslint-sast)
            'Javascript Node'      | { 'package.json' => '' }                        | {}                                         | %w(nodejs-scan-sast)
            'HTML'                 | { 'index.html' => '' }                          | {}                                         | %w(eslint-sast)
            'Kubernetes Manifests' | { 'Chart.yaml' => '' }                          | { 'SCAN_KUBERNETES_MANIFESTS' => 'true' }  | %w(kubesec-sast)
            'Multiple languages'   | { 'app.java' => '', 'app.js' => '' }            | {}                                         | %w(eslint-sast spotbugs-sast)
            'PHP'                  | { 'app.php' => '' }                             | {}                                         | %w(phpcs-security-audit-sast)
            'Python'               | { 'app.py' => '' }                              | {}                                         | %w(bandit-sast)
            'Ruby'                 | { 'config/routes.rb' => '' }                    | {}                                         | %w(brakeman-sast)
            'Scala'                | { 'app.scala' => '' }                           | {}                                         | %w(spotbugs-sast)
            'Typescript'           | { 'app.ts' => '' }                              | {}                                         | %w(eslint-sast)
            'Typescript JSX'       | { 'app.tsx' => '' }                             | {}                                         | %w(eslint-sast)
            'Visual Basic'         | { 'app.vbproj' => '' }                          | {}                                         | %w(security-code-scan-sast)
          end

          with_them do
            before do
              variables.each do |(key, value)|
                create(:ci_variable, project: project, key: key, value: value)
              end
            end

            it 'creates a pipeline with the expected jobs' do
              expect(build_names).to include(*include_build_names)
            end
          end
        end
      end
    end
  end
end

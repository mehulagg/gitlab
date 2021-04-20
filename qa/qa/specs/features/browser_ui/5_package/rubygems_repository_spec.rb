# frozen_string_literal: true

module QA
  RSpec.describe 'Package', :orchestrated, :packages do
    describe 'RubyGems Repository' do
      include Runtime::Fixtures

      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'rubygems-package-project'
        end
      end

      let(:package) do
        Resource::Package.new.tap do |package|
          package.name = 'mygem'
          package.project = project
        end
      end

      let!(:runner) do
        Resource::Runner.fabricate! do |runner|
          runner.name = "qa-runner-#{Time.now.to_i}"
          runner.tags = ["runner-for-#{project.name}"]
          runner.executor = :docker
          runner.project = project
        end
      end

      let(:gitlab_address_with_port) do
        uri = URI.parse(Runtime::Scenario.gitlab_address)
        "#{uri.scheme}://#{uri.host}:#{uri.port}"
      end

      before do
        Feature.enable(:rubygem_packages)
      end

      after do
        runner.remove_via_api!
        package.remove_via_api!
        Feature.disable(:rubygem_packages)
      end

      it 'publishes and deletes a Ruby gem', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1131' do
        Flow::Login.sign_in

        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = project
          commit.commit_message = 'Add mygem.gemspec'
          commit.add_files([{
                            file_path: 'mygem.gemspec',
                            content:
                              <<~RUBY
                                Gem::Specification.new do |s|
                                  s.name = #{package.name}
                                  s.authors = ['Tanuki Steve', 'Hal 9000']
                                  s.author = 'Tanuki Steve'
                                  s.version = '0.0.1'
                                  s.date = '2011-09-29'
                                  s.summary = 'package is the best'
                                  s.files = ['lib/test_gem.rb']
                                  s.require_paths = ['lib']

                                  s.description = 'A test package for GitLab.'
                                  s.email = 'tanuki@not_real.com'
                                  s.homepage = 'https://gitlab.com/ruby-co/my-package'
                                  s.license = 'MIT'

                                  s.metadata = {
                                    'bug_tracker_uri' => 'https://gitlab.com/ruby-co/my-package/issues',
                                    'changelog_uri' => 'https://gitlab.com/ruby-co/my-package/CHANGELOG.md',
                                    'documentation_uri' => 'https://gitlab.com/ruby-co/my-package/docs',
                                    'mailing_list_uri' => 'https://gitlab.com/ruby-co/my-package/mailme',
                                    'source_code_uri' => 'https://gitlab.com/ruby-co/my-package'
                                  }

                                  s.bindir = 'bin'
                                  s.executables = ['rake']
                                  s.extensions = ['ext/foo.rb']
                                  s.extra_rdoc_files = ['README.md', 'doc/userguide.md']
                                  s.platform = Gem::Platform::RUBY
                                  s.post_install_message = 'Installed, thank you!'
                                  s.rdoc_options = ['--main', 'README.md']
                                  s.required_ruby_version = '>= 2.7.0'
                                  s.required_rubygems_version = '>= 1.8.11'
                                  s.requirements = 'A high powered server or calculator'
                                  s.rubygems_version = '1.8.09'

                                  s.add_dependency 'dependency_1', '~> 1.2.3'
                                  s.add_dependency 'dependency_2', '3.0.0'
                                  s.add_dependency 'dependency_3', '>= 1.0.0'
                                  s.add_dependency 'dependency_4'
                                end
                              RUBY
                          }])
          commit.add_files([{
                            file_path: '.gem/credentials',
                            content:
                              <<~SHELL
                                ---
                                #{gitlab_address_with_port}/api/v4/projects/${env.CI_PROJECT_ID}/packages/rubygems: '${env.CI_JOB_TOKEN}'
                              SHELL
                          }])
          commit.add_files([{
                            file_path: '.gitlab-ci.yml',
                            content:
                              <<~YAML
                                image: ruby

                                test_package:
                                  stage: deploy
                                  script:
                                    - gem build mygem
                                    - gem push mygem-0.0.1.gem --host #{gitlab_address_with_port}/api/v4/projects/${CI_PROJECT_ID}/packages/rubygems
                                  tags:
                                    - "runner-for-#{project.name}"
                              YAML
                          }])
        end

        project.visit!
        Flow::Pipeline.visit_latest_pipeline

        Page::Project::Pipeline::Show.perform do |pipeline|
          pipeline.click_job('test_package')
        end

        Page::Project::Job::Show.perform do |job|
          expect(job).to be_successful(timeout: 800)
        end

        Page::Project::Menu.perform(&:click_packages_link)

        Page::Project::Packages::Index.perform do |index|
          expect(index).to have_package(package.name)
          index.click_package(package.name)
        end

        Page::Project::Packages::Show.perform(&:click_delete)

        Page::Project::Packages::Index.perform do |index|
          expect(index).to have_content("Package deleted successfully")
          expect(index).not_to have_package(package.name)
        end
      end
    end
  end
end

module QA
    # verify if dependency proxy is enabled in test environments.
    # does it need to have the packages tag?
  RSpec.describe 'Package', :orchestrated, :packages do
    describe 'Dependency Proxy' do
      # create project
      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'dependency-proxy-project'
        end
      end
      # ensure project has a sub group with feature enabled 

      # create runner
      let!(:runner) do
        Resource::Runner.fabricate! do |runner|
          runner.name = "qa-runner-#{Time.now.to_i}"
          runner.tags = ["runner-for-#{project.name}"]
          runner.executor = :docker
          runner.project = project
        end
      end

      before do
        Flow::Login.sign_in
        project.group.visit!

        Page::Group::Menu.perform(&:go_to_dependency_proxy)
        Page::Group::DependencyProxy.perform do |index|
          expect(index).to have_dependency_proxy_enabled
        end
      end

      after do
        runner.remove_via_api!
      end

      # parameterized to include different docker versions
      it 'pulls an image using the dependency proxy' do
          # commits a gitlab-ci file with two jobs
        Resource::Repository::Commit.fabricate_via_api! do |commit|
            commit.project = project
            commit.commit_message = 'Add .gitlab-ci.yml'
            commit.add_files([{
                                  file_path: '.gitlab-ci.yml',
                                  content:
                                      <<~YAML

                                        
                                      YAML
                              }])
          end
          # 1 job with pull image from docker hub and validating using the rate limit script
          # 2 job with pull same image from the dependency cache and validating using the rate limit script
      end
    end
  end
end

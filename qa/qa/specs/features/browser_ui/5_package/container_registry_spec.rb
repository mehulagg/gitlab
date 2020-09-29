# frozen_string_literal: true

module QA
  RSpec.describe 'Package', :orchestrated do
    describe 'Container Repository' do
      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'project-with-registry'
        end
      end

      let!(:runner) do
        Resource::Runner.fabricate! do |runner|
          runner.name = "qa-runner-#{Time.now.to_i}"
          runner.run_untagged = true
          runner.executor = :docker
          runner.project = project
        end
      end

      after do
        runner.remove_via_api!
      end

      it "pushes to the container registry" do
        Flow::Login.sign_in
        project.visit!

        Resource::Repository::ProjectPush.fabricate! do |push|
          push.project = project
          push.directory = Pathname
                               .new(__dir__)
                               .join('../../../../fixtures/auto_devops_rack')
          push.commit_message = 'Add rack application'
        end

        Resource::Repository::ProjectPush.fabricate! do |push|
          push.project = project
          push.new_branch = false
          push.directory = Pathname
                               .new(__dir__)
                               .join('../../../../fixtures/registry')
          push.commit_message = 'Add gitlab-ci file'
        end

        Resource::Pipeline.fabricate_via_api! do |pipeline|
          pipeline.project = project
        end.visit!

        Page::Project::Pipeline::Show.perform do |pipeline|
          pipeline.click_job('build')
        end

        Page::Project::Job::Show.perform do |job|
          expect(job).to be_successful(timeout: 600)
        end

        Page::Project::Menu.perform(&:click_container_registry_link)
      end
    end
  end
end

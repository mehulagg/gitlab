# frozen_string_literal: true

module QA
  RSpec.describe 'Package', :orchestrated, :packages do
    describe 'NuGet Repository' do
      include Runtime::Fixtures

      let(:package_name) { 'dotnetcore' }
      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'nuget-package-project'
          project.template_name = 'dotnetcore'
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

      it 'publishes a nuget package and deletes it' do
        Flow::Login.sign_in

        Resource::Repository::ProjectPush.fabricate! do |push|
          push.project = project
          push.new_branch = false
          push.directory = Pathname
                               .new(__dir__)
                               .join('../../../../fixtures/package_managers/nuget')
          push.commit_message = 'Add gitlab-ci file for nuget deploy'
        end

        Resource::Pipeline.fabricate_via_api! do |pipeline|
          pipeline.project = project
        end.visit!

        Page::Project::Pipeline::Show.perform do |pipeline|
          pipeline.click_job('deploy')
        end

        Page::Project::Job::Show.perform do |job|
          expect(job).to be_successful(timeout: 800)
        end

        Page::Project::Menu.perform(&:click_packages_link)

        Page::Project::Packages::Index.perform do |index|
          expect(index).to have_package(package_name)
          index.click_package(package_name)
        end

        Page::Project::Packages::Show.perform do |package|
          package.click_delete
        end

        Page::Project::Packages::Index.perform do |index|
          expect(index).to have_content("Package deleted successfully")
          expect(index).to have_no_package(package_name)
        end
      end
    end
  end
end

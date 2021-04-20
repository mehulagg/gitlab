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

            after do
                runner.remove_via_api!
                package.remove_via_api!
                project.remove_via_api!
            end

            it 'publishes and deletes a RubyGem', testcase: '' do 
            
            end
            
        end
    end
end
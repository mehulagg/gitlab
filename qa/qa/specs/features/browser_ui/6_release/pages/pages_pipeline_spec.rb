# frozen_string_literal: true

module QA
  RSpec.describe 'Release' do
    describe 'Pages' do
      let!(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'jekyll-pages-project'
          project.template_name = :jekyll
        end
      end

      let(:pipeline) do
        Resource::Pipeline.fabricate_via_api! do |pipeline|
          pipeline.project = project
        end
      end

      before do
        Flow::Login.sign_in
        pipeline.visit!
      end

      it 'runs a Pages-specific pipeline', :smoke do
        Page::Project::Pipeline::Show.perform do |show|
          expect(show).to have_job(:pages)
          expect(show).to have_passed
        end
      end
    end
  end
end

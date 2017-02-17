module QA
  feature 'create a new project', :ce, :ee, :staging do
    scenario 'user creates a new project' do
      Page::Main::Entry.act { sign_in_using_credentials }

      Scenario::Gitlab::Project::Create.perform do |project|
        project.name = 'awesome-project'
        project.description = 'create awesome project test'
      end

      expect(page).to have_content(
        /Project \S?awesome-project\S+ was successfully created/
      )

      expect(page).to have_content('create awesome project test')
      expect(page).to have_content('The repository for this project is empty')
    end
  end
end

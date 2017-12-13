module QA
  feature 'GitLab Geo replication', :geo do
    scenario 'users pushes code to the primary node' do
      Runtime::Browser.visit(:geo_primary, QA::Page::Main::Login) do
        Page::Main::Login.act { sign_in_using_credentials }

        Scenario::Gitlab::Project::Create.perform do |scenario|
          scenario.name = 'geo-project'
          scenario.description = 'Geo test project'
        end

        geo_project_name = Page::Project::Show.act { project_name }
        expect(geo_project_name).to include 'geo-project'

        Git::Repository.perform do |repository|
          repository.location = Page::Project::Show.act do
            choose_repository_clone_http
            repository_location
          end

          repository.use_default_credentials

          repository.act do
            clone
            configure_identity('GitLab QA', 'root@gitlab.com')
            add_file('README.md', '# This is Geo project!')
            commit('Add README.md')
            push_changes
          end
        end

        Runtime::Browser.visit(:geo_secondary, QA::Page::Main::Login) do
          Page::Main::OAuth.act do
            authorize! if needs_authorization?
          end

          expect(page).to have_content 'You are on a secondary (read-only) Geo node'

          Page::Main::Menu.perform do |menu|
            menu.go_to_projects

            expect(page).to have_content(geo_project_name)
          end

          sleep 10 # wait for repository replication

          Page::Dashboard::Projects.perform do |dashboard|
            dashboard.go_to_project(geo_project_name)
          end

          Page::Project::Show.perform do
            expect(page).to have_content 'README.md'
            expect(page).to have_content 'This is Geo project!'
          end
        end
      end
    end
  end
end

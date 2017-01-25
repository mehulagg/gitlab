module QA
  feature 'clone code from the repository', :ce, :ee, :staging do
    context 'with regular account over http' do
      given(:location) do
        Page::Project::Show.act do
          choose_repository_clone_http
          repository_location
        end
      end

      before do
        Page::Main::Entry.act { sign_in_using_credentials }

        Scenario::Gitlab::Project::Create.perform do |scenario|
          scenario.name = 'project-with-code'
          scenario.description = 'project for git clone tests'
        end

        Git::Repository.perform do |repository|
          repository.location = location
          repository.use_default_credentials

          repository.act do
            clone
            configure_identity('GitLab QA', 'root@gitlab.com')
            commit_file('test.rb', 'class Test; end', 'Add Test class')
            commit_file('README.md', '# Test', 'Add Readme')
            push_changes
          end
        end
      end

      scenario 'user performs a deep clone' do
        Git::Repository.perform do |repository|
          repository.location = location
          repository.use_default_credentials

          repository.act { clone }

          expect(repository.commits.size).to eq 2
        end
      end

      scenario 'user performs a shallow clone' do
        Git::Repository.perform do |repository|
          repository.location = location
          repository.use_default_credentials

          repository.act { shallow_clone }

          expect(repository.commits.size).to eq 1
          expect(repository.commits.first).to include 'Add Readme'
        end
      end
    end
  end
end

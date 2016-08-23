feature 'clone code from the repository', ce: true, staging: true do
  context 'with regular account over http' do
    before do
      Page::Main::Entry.act { sign_in_using_credentials }

      Scenario::Project::Create.perform do
        with_random_project_name
        with_project_description 'project for git clone tests'
      end
    end

    given(:repository) do
      Page::Project::Show.act do
        choose_repository_clone_http
        repository_clone_uri
      end
    end

    background do
      Git::Repository.act(repository: repository) do
        with_location(@repository)
        with_username(Run::User.name)
        with_password(Run::User.password)

        clone_repository
        configure_identity('GitLab QA', 'root@gitlab.com')
        commit_file('test.rb', 'class Test; end', 'Add Test class')
        commit_file('README.md', '# Test', 'Add Readme')
        push_changes
      end
    end

    scenario 'user performs a deep clone' do
      Git::Repository.act(repository: repository) do
        with_location(@repository)
        with_username(Run::User.name)
        with_password(Run::User.password)

        clone_repository

        expect(commits.size).to eq 2
      end
    end

    scenario 'user performs a shallow clone'
  end
end

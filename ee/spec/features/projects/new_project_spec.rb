require 'spec_helper'

describe 'New project' do
  let(:user) { create(:admin) }

  before do
    sign_in(user)
  end

  context 'Namespace selector' do
    context 'with group with DEVELOPER_MAINTAINER_PROJECT_ACCESS project_creation_level' do
      let(:group) { create(:group, project_creation_level: ::EE::Gitlab::Access::DEVELOPER_MAINTAINER_PROJECT_ACCESS) }

      before do
        group.add_developer(user)
        visit new_project_path(namespace_id: group.id)
      end

      it 'selects the group namespace' do
        page.within('#blank-project-pane') do
          namespace = find('#project_namespace_id option[selected]')

          expect(namespace.text).to eq group.full_path
        end
      end
    end
  end

  context 'repository mirrors' do
    context 'when licensed' do
      before do
        stub_licensed_features(repository_mirrors: true)
      end

      it 'shows mirror repository checkbox enabled', :js do
        visit new_project_path
        find('#import-project-tab').click
        first('.js-import-git-toggle-button').click

        expect(page).to have_unchecked_field('Mirror repository', disabled: false)
      end
    end

    context 'when unlicensed' do
      before do
        stub_licensed_features(repository_mirrors: false)
      end

      it 'does not show mirror repository option' do
        visit new_project_path
        first('.js-import-git-toggle-button').click

        expect(page).not_to have_content('Mirror repository')
      end
    end
  end

  context 'CI/CD for external repositories', :js do
    let(:repo) do
      OpenStruct.new(
        id: 123,
        login: 'some-github-repo',
        owner: OpenStruct.new(login: 'some-github-repo'),
        name: 'some-github-repo',
        full_name: 'my-user/some-github-repo',
        clone_url: 'https://github.com/my-user/some-github-repo.git'
      )
    end

    context 'when licensed' do
      before do
        stub_licensed_features(ci_cd_projects: true)
      end

      it 'shows CI/CD tab and pane' do
        visit new_project_path

        expect(page).to have_css('#ci-cd-project-tab')

        find('#ci-cd-project-tab').click

        expect(page).to have_css('#ci-cd-project-pane')
      end

      it '"Import project" tab creates projects with features enabled' do
        visit new_project_path
        find('#import-project-tab').click

        page.within '#import-project-pane' do
          first('.js-import-git-toggle-button').click

          fill_in 'project_import_url', with: 'http://foo.git'
          fill_in 'project_name', with: 'import-project-with-features1'
          fill_in 'project_path', with: 'import-project-with-features1'
          choose 'project_visibility_level_20'
          click_button 'Create project'

          created_project = Project.last

          if Gitlab.rails5?
            expect(current_path).to eq(project_import_path(created_project))
          else
            expect(current_path).to eq(project_path(created_project))
          end

          expect(created_project.project_feature).to be_issues_enabled
        end
      end

      it 'creates CI/CD project from repo URL' do
        visit new_project_path
        find('#ci-cd-project-tab').click

        page.within '#ci-cd-project-pane' do
          find('.js-import-git-toggle-button').click

          fill_in 'project_import_url', with: 'http://foo.git'
          fill_in 'project_name', with: 'CI CD Project1'
          fill_in 'project_path', with: 'ci-cd-project1'
          choose 'project_visibility_level_20'
          click_button 'Create project'

          created_project = Project.last
          expect(current_path).to eq(project_path(created_project))
          expect(created_project.mirror).to eq(true)
          expect(created_project.project_feature).not_to be_issues_enabled
        end
      end

      it 'creates CI/CD project from GitHub' do
        visit new_project_path
        find('#ci-cd-project-tab').click

        page.within '#ci-cd-project-pane' do
          find('.js-import-github').click
        end

        expect(page).to have_text('Connect repositories from GitHub')

        allow_any_instance_of(Gitlab::LegacyGithubImport::Client).to receive(:repos).and_return([repo])

        fill_in 'personal_access_token', with: 'fake-token'
        click_button 'List your GitHub repositories'
        wait_for_requests

        # Mock the POST `/import/github`
        allow_any_instance_of(Gitlab::LegacyGithubImport::Client).to receive(:repo).and_return(repo)
        project = create(:project, name: 'some-github-repo', creator: user, import_type: 'github')
        create(:import_state, :finished, import_url: repo.clone_url, project: project)
        allow_any_instance_of(CiCd::SetupProject).to receive(:setup_external_service)
        CiCd::SetupProject.new(project, user).execute
        allow_any_instance_of(Gitlab::LegacyGithubImport::ProjectCreator)
          .to receive(:execute).with(hash_including(ci_cd_only: true))
          .and_return(project)

        click_button 'Connect'
        wait_for_requests

        expect(page).to have_text('Started')
        wait_for_requests

        expect(page).to have_text('Done')

        created_project = Project.last
        expect(created_project.name).to eq('some-github-repo')
        expect(created_project.mirror).to eq(true)
        expect(created_project.project_feature).not_to be_issues_enabled
      end

      it 'new GitHub CI/CD project page has link to status page with ?ci_cd_only=true param' do
        visit new_import_github_path(ci_cd_only: true)

        expect(page).to have_link('List your GitHub repositories', href: status_import_github_path(ci_cd_only: true))
      end

      it 'stays on GitHub import page after access token failure' do
        visit new_project_path
        find('#ci-cd-project-tab').click

        page.within '#ci-cd-project-pane' do
          find('.js-import-github').click
        end

        allow_any_instance_of(Gitlab::LegacyGithubImport::Client).to receive(:repos).and_raise(Octokit::Unauthorized)

        fill_in 'personal_access_token', with: 'unauthorized-fake-token'
        click_button 'List your GitHub repositories'

        expect(page).to have_text('Access denied to your GitHub account.')
        expect(page).to have_current_path(new_import_github_path(ci_cd_only: true))
      end
    end

    context 'when unlicensed' do
      before do
        stub_licensed_features(ci_cd_projects: false)
      end

      it 'does not show CI/CD only tab' do
        visit new_project_path

        expect(page).not_to have_css('#ci-cd-project-tab')
      end
    end
  end

  context 'Group-level project templates', :js, :postgresql do
    let(:url) { new_project_path }

    context 'when licensed' do
      before do
        stub_licensed_features(custom_project_templates: true)
      end

      it 'shows Group tab in Templates section' do
        visit url
        click_link 'Create from template'

        expect(page).to have_css('.group-templates-tab')
      end

      shared_examples 'group templates displayed' do
        before do
          visit url
          click_link 'Create from template'

          page.within('#create-from-template-pane') do
            click_link 'Group'
            wait_for_all_requests
          end
        end

        it 'the tab badge displays the number of templates available' do
          page.within('.group-templates-tab') do
            expect(page).to have_selector('span.badge', text: template_number)
          end
        end

        it 'the tab shows the list of templates available' do
          page.within('#group-templates') do
            expect(page).to have_selector('.template-option', count: template_number)
          end
        end
      end

      shared_examples 'template selected' do
        before do
          visit url
          click_link 'Create from template'

          page.within('#create-from-template-pane') do
            click_link 'Group'
            wait_for_all_requests
          end

          page.within('.custom-project-templates') do
            page.find(".template-option input[value='#{subgroup1_project1.name}']").first(:xpath, './/..').click
            wait_for_all_requests
          end
        end

        context 'when template is selected' do
          context 'namespace selector' do
            it "only shows the template's group hierarchy options" do
              page.within('#create-from-template-pane') do
                elements = page.find_all("#project_namespace_id option:not(.hidden)", visible: false).map { |e| e['data-name'] }
                expect(elements).to contain_exactly(group1.name, subgroup1.name, subsubgroup1.name)
              end
            end

            it 'does not show the user namespace options' do
              page.within('#create-from-template-pane') do
                expect(page.find_all("#project_namespace_id optgroup.hidden[label='Users']", visible: false)).not_to be_empty
              end
            end
          end
        end

        context 'when user changes template' do
          let(:url) { new_project_path }

          before do
            page.within('#create-from-template-pane') do
              click_button 'Change template'

              page.find(".template-option input[value='#{subgroup2_project.name}']").first(:xpath, './/..').click

              wait_for_all_requests
            end
          end

          it 'list the appropriate groups' do
            page.within('#create-from-template-pane') do
              elements = page.find_all("#project_namespace_id option:not(.hidden)", visible: false).map { |e| e['data-name'] }

              expect(elements).to contain_exactly(group2.name, subgroup2.name)
            end
          end
        end
      end

      context 'when custom project group template is set' do
        let(:group1) { create(:group) }
        let(:group2) { create(:group) }
        let(:subgroup1) { create(:group, parent: group1) }
        let(:subgroup2) { create(:group, parent: group2) }
        let(:subsubgroup1) { create(:group, parent: subgroup1) }
        let!(:subgroup1_project1) { create(:project, namespace: subgroup1) }
        let!(:subgroup1_project2) { create(:project, namespace: subgroup1) }
        let!(:subgroup2_project) { create(:project, namespace: subgroup2) }
        let!(:subsubgroup1_project) { create(:project, namespace: subsubgroup1) }

        before do
          group1.add_owner(user)
          group2.add_owner(user)
          group1.update(custom_project_templates_group_id: subgroup1.id)
          group2.update(custom_project_templates_group_id: subgroup2.id)
        end

        context 'when top level context' do
          it_behaves_like 'group templates displayed' do
            let(:template_number) { 3 }
          end

          it_behaves_like 'template selected'
        end

        context 'when namespace context' do
          let(:url) { new_project_path(namespace_id: group1.id) }

          it_behaves_like 'group templates displayed' do
            let(:template_number) { 2 }
          end

          it_behaves_like 'template selected'
        end
      end

      context 'when group template is not set' do
        it_behaves_like 'group templates displayed' do
          let(:template_number) { 0 }
        end
      end
    end

    context 'when unlicensed' do
      before do
        stub_licensed_features(custom_project_templates: false)
      end

      it 'does not show Group tab in Templates section' do
        visit url
        click_link 'Create from template'

        expect(page).not_to have_css('.group-templates-tab')
      end
    end
  end
end

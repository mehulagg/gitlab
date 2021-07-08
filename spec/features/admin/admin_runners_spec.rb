# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Admin Runners" do
  include StubENV

  before do
    stub_env('IN_MEMORY_APPLICATION_SETTINGS', 'false')
    admin = create(:admin)
    sign_in(admin)
    gitlab_enable_admin_mode_sign_in(admin)
  end

  describe "Runners page", :js do
    let_it_be(:user) { create(:user) }
    let_it_be(:group) { create(:group) }
    let_it_be(:namespace) { create(:namespace) }
    let_it_be(:project) { create(:project, namespace: namespace, creator: user) }
    let_it_be(:runner_args) { { version: '1.0.0', revision: '123', ip_address: '127.0.0.1' } }

    context "when there are runners" do
      it 'has all necessary texts' do
        create(:ci_runner, contacted_at: Time.now)
        visit admin_runners_path

        expect(page).to have_text "Set up a shared runner manually"
        expect(page).to have_text "Runners currently online: 1"
      end

      it 'shows the label and does not show the project count' do
        runner = create(:ci_runner, :instance, description: 'runner-group', **runner_args)

        visit admin_runners_path

        within "[data-testid='runner-row-#{runner.id}']" do
          expect(page).to have_selector '.badge', text: 'shared'
          expect(page).to have_text 'n/a'
        end
      end

      it 'shows the label and does not show the project count' do
        runner = create(:ci_runner, :group, description: 'runner-group', groups: [group], **runner_args)

        visit admin_runners_path

        within "[data-testid='runner-row-#{runner.id}']" do
          expect(page).to have_selector '.badge', text: 'group'
          expect(page).to have_text 'n/a'
        end
      end

      it 'shows the label and the project count' do
        runner = create(:ci_runner, :project, description: 'runner-project', projects: [project], **runner_args)

        visit admin_runners_path

        within "[data-testid='runner-row-#{runner.id}']" do
          expect(page).to have_selector '.badge', text: 'specific'
          expect(page).to have_text '1'
        end
      end

      describe 'search' do
        before do
          create(:ci_runner, :instance, description: 'runner-foo', **runner_args)
          create(:ci_runner, :instance, description: 'runner-bar', **runner_args)

          visit admin_runners_path
        end

        it 'shows runners' do
          expect(page).to have_content("runner-foo")
          expect(page).to have_content("runner-bar")
        end

        it 'shows correct runner when description matches' do
          input_filtered_search_keys('runner-foo')

          expect(page).to have_content("runner-foo")
          expect(page).not_to have_content("runner-bar")
        end

        it 'shows no runner when description does not match' do
          input_filtered_search_keys('runner-baz')

          expect(page).to have_text 'No runners found'
        end
      end

      describe 'filter by status' do
        it 'shows correct runner when status matches' do
          create(:ci_runner, :instance, description: 'runner-active', active: true, **runner_args)
          create(:ci_runner, :instance, description: 'runner-paused', active: false, **runner_args)

          visit admin_runners_path

          expect(page).to have_content 'runner-active'
          expect(page).to have_content 'runner-paused'

          input_filtered_search_filter_is_only('Status', 'Active')

          expect(page).to have_content 'runner-active'
          expect(page).not_to have_content 'runner-paused'
        end

        it 'shows no runner when status does not match' do
          create(:ci_runner, :instance, description: 'runner-active', active: true, **runner_args)
          create(:ci_runner, :instance, description: 'runner-paused', active: false, **runner_args)

          visit admin_runners_path

          input_filtered_search_filter_is_only('Status', 'Online')

          expect(page).not_to have_content 'runner-active'
          expect(page).not_to have_content 'runner-paused'

          expect(page).to have_text 'No runners found'
        end

        it 'shows correct runner when status is selected and search term is entered' do
          create(:ci_runner, :instance, description: 'runner-a-1', active: true, **runner_args)
          create(:ci_runner, :instance, description: 'runner-a-2', active: false, **runner_args)
          create(:ci_runner, :instance, description: 'runner-b-1', active: true, **runner_args)

          visit admin_runners_path

          input_filtered_search_filter_is_only('Status', 'Active')

          expect(page).to have_content 'runner-a-1'
          expect(page).to have_content 'runner-b-1'
          expect(page).not_to have_content 'runner-a-2'

          input_filtered_search_keys('runner-a')

          expect(page).to have_content 'runner-a-1'
          expect(page).not_to have_content 'runner-b-1'
          expect(page).not_to have_content 'runner-a-2'
        end
      end

      describe 'filter by type' do
        before do
          create(:ci_runner, :project, description: 'runner-project', projects: [project], **runner_args)
          create(:ci_runner, :group, description: 'runner-group', groups: [group], **runner_args)
        end

        it 'shows correct runner when type matches' do
          visit admin_runners_path

          expect(page).to have_content 'runner-project'
          expect(page).to have_content 'runner-group'

          input_filtered_search_filter_is_only('Type', 'project')

          expect(page).to have_content 'runner-project'
          expect(page).not_to have_content 'runner-group'
        end

        it 'shows no runner when type does not match' do
          visit admin_runners_path

          input_filtered_search_filter_is_only('Type', 'instance')

          expect(page).not_to have_content 'runner-project'
          expect(page).not_to have_content 'runner-group'

          expect(page).to have_text 'No runners found'
        end

        it 'shows correct runner when type is selected and search term is entered' do
          create(:ci_runner, :project, description: 'runner-2-project', projects: [project], **runner_args)

          visit admin_runners_path

          input_filtered_search_filter_is_only('Type', 'project')
          expect(page).to have_content 'runner-project'
          expect(page).to have_content 'runner-2-project'
          expect(page).not_to have_content 'runner-group'

          input_filtered_search_keys('runner-project')
          expect(page).to have_content 'runner-project'
          expect(page).not_to have_content 'runner-2-project'
          expect(page).not_to have_content 'runner-group'
        end
      end

      describe 'filter by tag' do
        before do
          create(:ci_runner, :instance, description: 'runner-blue', tag_list: ['blue'], **runner_args)
          create(:ci_runner, :instance, description: 'runner-red', tag_list: ['red'], **runner_args)
        end

        it 'shows correct runner when tag matches' do
          visit admin_runners_path

          expect(page).to have_content 'runner-blue'
          expect(page).to have_content 'runner-red'

          input_filtered_search_filter_is_only('Tags', 'blue')

          expect(page).to have_content 'runner-blue'
          expect(page).not_to have_content 'runner-red'
        end

        it 'shows no runner when tag does not match' do
          visit admin_runners_path

          input_filtered_search_filter_is_only('Tags', 'green')

          expect(page).not_to have_content 'runner-blue'
          expect(page).to have_text 'No runners found'
        end

        it 'shows correct runner when tag is selected and search term is entered' do
          create(:ci_runner, :instance, description: 'runner-2-blue', tag_list: ['blue'], **runner_args)

          visit admin_runners_path

          input_filtered_search_filter_is_only('Tags', 'blue')

          expect(page).to have_content 'runner-blue'
          expect(page).to have_content 'runner-2-blue'
          expect(page).not_to have_content 'runner-red'

          input_filtered_search_keys('runner-2-blue')

          expect(page).to have_content 'runner-2-blue'
          expect(page).not_to have_content 'runner-blue'
          expect(page).not_to have_content 'runner-red'
        end
      end

      it 'sorts by last contact date' do
        create(:ci_runner, :instance, description: 'runner-1', created_at: '2018-07-12 15:37', contacted_at: '2018-07-12 15:37', **runner_args)
        create(:ci_runner, :instance, description: 'runner-2', created_at: '2018-07-12 16:37', contacted_at: '2018-07-12 16:37', **runner_args)

        visit admin_runners_path

        within '[data-testid="runner-list"] tbody tr:nth-child(1)' do
          expect(page).to have_content 'runner-2'
        end

        within '[data-testid="runner-list"] tbody tr:nth-child(2)' do
          expect(page).to have_content 'runner-1'
        end

        click_on 'Created date' # Open "sort by" dropdown
        click_on 'Last contact'
        click_on 'Sort direction: Descending'

        within '[data-testid="runner-list"] tbody tr:nth-child(1)' do
          expect(page).to have_content 'runner-1'
        end

        within '[data-testid="runner-list"] tbody tr:nth-child(2)' do
          expect(page).to have_content 'runner-2'
        end
      end
    end

    context "when there are no runners" do
      before do
        visit admin_runners_path
      end

      it 'has all necessary texts including no runner message' do
        expect(page).to have_text "Set up a shared runner manually"
        expect(page).to have_text "Runners currently online: 0"
        expect(page).to have_text 'No runners found'
      end
    end

    describe 'runners registration token' do
      let!(:token) { Gitlab::CurrentSettings.runners_registration_token }

      before do
        visit admin_runners_path
      end

      it 'has a registration token' do
        expect(page.find('[data-testid="registration-token"]')).to have_content(token)
      end

      describe 'reset registration token' do
        let(:page_token) { find('[data-testid="registration-token"]').text }

        before do
          click_button 'Reset registration token'

          page.accept_alert

          wait_for_requests
        end

        it 'changes registration token' do
          expect(page_token).not_to eq token
        end
      end
    end
  end

  describe "Runner show page" do
    let(:runner) { create(:ci_runner) }

    before do
      @project1 = create(:project)
      @project2 = create(:project)
      visit admin_runner_path(runner)
    end

    describe 'runner page breadcrumbs' do
      it 'contains the current runner token' do
        page.within '[data-testid="breadcrumb-links"]' do
          expect(page.find('h2')).to have_content(runner.short_sha)
        end
      end
    end

    describe 'runner page title', :js do
      it 'contains the runner id' do
        expect(find('.page-title')).to have_content("Runner ##{runner.id}")
      end
    end

    describe 'projects' do
      it 'contains project names' do
        expect(page).to have_content(@project1.full_name)
        expect(page).to have_content(@project2.full_name)
      end
    end

    describe 'search' do
      before do
        search_form = find('#runner-projects-search')
        search_form.fill_in 'search', with: @project1.name
        search_form.click_button 'Search'
      end

      it 'contains name of correct project' do
        expect(page).to have_content(@project1.full_name)
        expect(page).not_to have_content(@project2.full_name)
      end
    end

    describe 'enable/create' do
      shared_examples 'assignable runner' do
        it 'enables a runner for a project' do
          within '[data-testid="unassigned-projects"]' do
            click_on 'Enable'
          end

          assigned_project = page.find('[data-testid="assigned-projects"]')

          expect(assigned_project).to have_content(@project2.path)
        end
      end

      context 'with specific runner' do
        let(:runner) { create(:ci_runner, :project, projects: [@project1]) }

        before do
          visit admin_runner_path(runner)
        end

        it_behaves_like 'assignable runner'
      end

      context 'with locked runner' do
        let(:runner) { create(:ci_runner, :project, projects: [@project1], locked: true) }

        before do
          visit admin_runner_path(runner)
        end

        it_behaves_like 'assignable runner'
      end

      context 'with shared runner' do
        let(:runner) { create(:ci_runner, :instance) }

        before do
          @project1.destroy!
          visit admin_runner_path(runner)
        end

        it_behaves_like 'assignable runner'
      end
    end

    describe 'disable/destroy' do
      let(:runner) { create(:ci_runner, :project, projects: [@project1]) }

      before do
        visit admin_runner_path(runner)
      end

      it 'enables specific runner for project' do
        within '[data-testid="assigned-projects"]' do
          click_on 'Disable'
        end

        new_runner_project = page.find('[data-testid="unassigned-projects"]')

        expect(new_runner_project).to have_content(@project1.path)
      end
    end
  end

  private

  @search_bar_selector = '[data-testid="runners-filtered-search"]'

  # The filters must be clicked first to a able to receive events
  # See: https://gitlab.com/gitlab-org/gitlab-ui/-/issues/1493
  def focus_filtered_search(selector = @search_bar_selector)
    page.within(selector) do
      page.find('.gl-filtered-search-term-token').click
    end
  end

  def input_filtered_search_keys(search_term, selector = @search_bar_selector)
    focus_filtered_search(selector)

    page.within(selector) do
      page.find('.gl-filtered-search-term-token').click

      page.find('input').send_keys(search_term)
      click_on 'Search'
    end
  end

  def input_filtered_search_filter_is_only(filter, value, selector = @search_bar_selector)
    focus_filtered_search(selector)

    page.within(selector) do
      # For OPERATOR_IS_ONLY, clicking filter immediately preselects operator
      click_on filter

      page.find('input').send_keys(value)
      page.find('input').send_keys(:enter)

      click_on 'Search'
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Epic in issue sidebar', :js do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, :public) }
  let_it_be(:epic1) { create(:epic, group: group, title: 'Foo') }
  let_it_be(:epic2) { create(:epic, group: group, title: 'Bar') }
  let_it_be(:epic3) { create(:epic, group: group, title: 'Baz') }
  let_it_be(:project) { create(:project, :public, group: group) }
  let_it_be(:issue) { create(:issue, project: project) }
  let_it_be(:epic_issue) { create(:epic_issue, epic: epic1, issue: issue) }

  shared_examples 'epic in issue sidebar' do
    context 'projects within a group' do
      before do
        group.add_owner(user)
        sign_in user
        visit project_issue_path(project, issue)
        wait_for_all_requests
      end

      it 'shows epic in issue sidebar' do
        expect(page.find('[data-testid="sidebar-epic"]')).to have_content(epic1.title)
      end

      it 'shows edit button in issue sidebar' do
        expect(page.find('[data-testid="sidebar-epic"]')).to have_button('Edit')
      end

      it 'shows epics select dropdown' do
        page.within(find('[data-testid="sidebar-epic"]')) do
          click_button 'Edit'

          wait_for_all_requests

          expect(page).to have_selector('.gl-new-dropdown-contents .gl-new-dropdown-item', count: 4) # `No Epic` + 3 epics
        end
      end

      it 'supports searching for an epic' do
        page.within(find('[data-testid="sidebar-epic"]')) do
          click_button 'Edit'

          wait_for_all_requests

          page.find('.gl-form-input').send_keys('Foo')

          wait_for_all_requests

          expect(page).to have_selector('.gl-new-dropdown-contents .gl-new-dropdown-item', count: 2) # `No Epic` + 1 matching epic
        end
      end

      it 'select an epic from the dropdown' do
        page.within(find('[data-testid="sidebar-epic"]')) do
          click_button 'Edit'

          wait_for_all_requests

          find('.gl-new-dropdown-item', text: epic2.title).click

          wait_for_all_requests

          expect(page.find('[data-testid="select-epic"]')).to have_content(epic2.title)
        end
      end
    end

    context 'personal projects' do
      it 'does not show epic in issue sidebar' do
        personal_project = create(:project, :public)
        other_issue = create(:issue, project: personal_project)

        visit project_issue_path(personal_project, other_issue)

        expect_no_epic
      end
    end
  end

  context 'when epics available' do
    before do
      stub_licensed_features(epics: true)

      sign_in(user)
    end

    it_behaves_like 'epic in issue sidebar'

    context 'with namespaced plans' do
      before do
        stub_application_setting(check_namespace_plan: true)
      end

      context 'group has license' do
        before do
          create(:gitlab_subscription, :ultimate, namespace: group)
        end

        it_behaves_like 'epic in issue sidebar'
      end

      context 'group has no license' do
        it 'does not show epic for public projects and groups' do
          visit project_issue_path(project, issue)

          expect_no_epic
        end
      end
    end
  end

  context 'when epics unavailable' do
    before do
      stub_licensed_features(epics: false)
    end

    it 'does not show epic in issue sidebar' do
      visit project_issue_path(project, issue)

      expect_no_epic
    end
  end

  def expect_no_epic
    expect(page).not_to have_selector('.block.epic')
  end
end

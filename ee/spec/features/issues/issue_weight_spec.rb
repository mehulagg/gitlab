# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Issue weight', :js do
  let_it_be(:project) { create(:project, :public) }
  let_it_be(:user) { create(:user) }

  before do
    project.add_developer(user)
    sign_in(user)
  end

  it 'allows user to update weight from none to something' do
    issue = create(:issue, author: user, project: project)

    visit project_issue_path(project, issue)

    page.within('.weight') do
      expect(page).to have_content "None"

      click_button 'Edit'

      find('.block.weight input').send_keys 1, :enter

      page.within('[data-testid="sidebar-weight-value"]') do
        expect(page).to have_content "1"
      end
    end
  end

  it 'allows user to update weight from one value to another' do
    issue = create(:issue, author: user, project: project, weight: 2)

    visit project_issue_path(project, issue)

    page.within('.weight') do
      expect(page).to have_content "2"

      click_button 'Edit'

      find('.block.weight input').send_keys 3, :enter

      page.within('[data-testid="sidebar-weight-value"]') do
        expect(page).to have_content "3"
      end
    end
  end

  it 'allows user to remove weight' do
    issue = create(:issue, author: user, project: project, weight: 5)

    visit project_issue_path(project, issue)

    page.within('.weight') do
      expect(page).to have_content "5"

      click_button 'remove weight'

      page.within('[data-testid="sidebar-weight-value"]') do
        expect(page).to have_content "None"
      end
    end
  end
end

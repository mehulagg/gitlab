# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Merge request > User selects branches for new MR', :js do
  let(:project) { create(:project, :public, :repository) }
  let(:user) { project.creator }

  def select_source_branch(branch_name)
    find('.js-source-branch', match: :first).click
    find('.js-source-branch-dropdown .dropdown-input-field').native.send_keys branch_name
    find('.js-source-branch-dropdown .dropdown-content a', text: branch_name, match: :first).click
  end

  before do
    project.add_maintainer(user)
    sign_in(user)
  end

  context 'create a merge request for the selected branches' do
    before do
      visit project_new_merge_request_path(project, merge_request: { target_branch: project.default_branch, source_branch: 'feature_conflict' })
    end

    context 'saving the MR' do
      it 'shows the saved MR' do
        fill_in 'merge_request_title', with: 'Test'
        click_button 'Create merge request'

        expect(page).to have_button('Close merge request')
      end
    end
  end
end

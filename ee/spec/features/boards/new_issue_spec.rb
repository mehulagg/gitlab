# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Issue Boards new issue', :js do
  let(:project) { create(:project, :public) }
  let(:board)   { create(:board, project: project) }
  let!(:list)   { create(:list, board: board, position: 0) }
  let(:user)    { create(:user) }

  context 'authorized user' do
    before do
      project.add_maintainer(user)

      sign_in(user)

      visit project_board_path(project, board)
      wait_for_requests

      expect(page).to have_selector('.board', count: 3)
    end

    it 'successfully assigns weight to newly-created issue' do
      page.within(first('.board')) do
        find('.issue-count-badge-add-button').click
      end

      page.within(first('.board-new-issue-form')) do
        find('.form-control').set('new issue')
        click_button 'Submit issue'
      end

      wait_for_requests

      page.within(first('.issue-boards-sidebar')) do
        find('.weight .js-weight-edit-link').click
        find('.weight .form-control').set("10\n")
      end

      wait_for_requests

      page.within(first('.board-card')) do
        expect(find('.board-card-weight .board-card-info-text').text).to eq("10")
      end
    end
  end
end

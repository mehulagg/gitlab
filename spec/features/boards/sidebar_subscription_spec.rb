# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Project issue boards sidebar subscription', :js do
  include BoardHelpers

  let(:user)         { create(:user) }
  let(:project)      { create(:project, :public) }
  let!(:development) { create(:label, project: project, name: 'Development') }
  let!(:regression)  { create(:label, project: project, name: 'Regression') }
  let!(:stretch)     { create(:label, project: project, name: 'Stretch') }
  let!(:issue1)      { create(:labeled_issue, project: project, labels: [development], relative_position: 2) }
  let!(:issue2)      { create(:labeled_issue, project: project, labels: [development], relative_position: 1) }
  let(:board)        { create(:board, project: project) }
  let!(:list)        { create(:list, board: board, label: development, position: 0) }
  let(:card)         { find('.board:nth-child(2)').first('.board-card') }

  before do
    project.add_maintainer(user)

    sign_in(user)

    visit project_board_path(project, board)
    wait_for_requests
  end

  context 'subscription' do
    it 'changes issue subscription' do
      click_card(card)
      wait_for_requests

      page.within('.subscriptions') do
        find('[data-testid="subscription-toggle"] button:not(.is-checked)').click
        wait_for_requests

        live_debug
        expect(page).to have_css('[data-testid="subscription-toggle"] button.is-checked')
      end
    end

    it 'has checked subscription toggle when already subscribed' do
      create(:subscription, user: user, project: project, subscribable: issue2, subscribed: true)
      visit project_board_path(project, board)
      wait_for_requests

      click_card(card)
      wait_for_requests

      page.within('.subscriptions') do
        find('[data-testid="subscription-toggle"] button.is-checked').click
        wait_for_requests

        expect(page).to have_css('[data-testid="subscription-toggle"] button:not(.is-checked)')
      end
    end
  end
end

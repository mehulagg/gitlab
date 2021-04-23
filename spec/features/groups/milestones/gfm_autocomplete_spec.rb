# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GFM autocomplete', :js do
  let_it_be(:user) { create(:user, name: '💃speciąl someone💃', username: 'someone.special') }
  let_it_be(:group) { create(:group, name: 'Ancestor') }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:issue) { create(:issue, project: project, assignees: [user]) }
  let_it_be(:label) { create(:group_label, group: group, title: 'special+') }

  before_all do
    group.add_maintainer(user)
  end

  describe 'new milestone page' do
    before do
      sign_in(user)
      visit new_group_milestone_path(group)

      wait_for_requests
    end

    it 'autocompletes usernames' do
      fill_in 'Description', with: "@username"

      wait_for_requests

      expect(find_autocomplete_menu).to be_visible
    end

    it 'autocompletes labels' do
      fill_in 'Description', with: "~spec"

      wait_for_requests

      expect(find_autocomplete_menu).to be_visible
    end
  end

  private

  def find_autocomplete_menu
    find('.atwho-view ul', visible: true)
  end
end

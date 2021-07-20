# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Dropdown epic', :js do
  include FilteredSearchHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:user) { create(:user) }
  let_it_be(:epic) { create(:epic, group: group) }
  let_it_be(:epic2) { create(:epic, group: group) }
  let_it_be(:issue) { create(:issue, project: project) }

  let(:filtered_search) { find('.filtered-search') }
  let(:js_dropdown_epic) { '#js-dropdown-epic' }
  let(:filter_dropdown) { find("#{js_dropdown_epic} .filter-dropdown") }

  before do
    stub_licensed_features(epics: true)

    group.add_maintainer(user)

    sign_in(user)

    visit issues_group_path(group)
  end

  describe 'behavior' do
    it 'loads all the epics when opened' do
      input_filtered_search('epic:=', submit: false, extra_space: false)

      expect_filtered_search_dropdown_results(filter_dropdown, 2)
    end

    it 'selects epic and correct title is loaded' do
      input_filtered_search('epic:=', submit: false, extra_space: false)
      wait_for_requests

      find('li', text: epic.title).click

      expect(find('.filtered-search-token .value').text).to eq("\"#{epic.title}\"::&#{epic.id}")
    end

    it 'filters issues by epic' do
      input_filtered_search('epic:=', submit: false, extra_space: false)
      wait_for_requests

      find('li', text: epic2.title).click

      expect(find('.issue-title-text').text).to eq("#{issue.title}")
    end
  end
end

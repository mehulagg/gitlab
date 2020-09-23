# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Dropdown weight', :js do
  include FilteredSearchHelpers

  let!(:project) { create(:project) }
  let!(:user) { create(:user) }
  let(:filtered_search) { find('.filtered-search') }
  let(:js_dropdown_weight) { '#js-dropdown-weight' }
  let(:filter_dropdown) { find("#{js_dropdown_weight} .filter-dropdown") }

  before do
    project.add_maintainer(user)
    sign_in(user)
    create(:issue, project: project)

    visit project_issues_path(project)
  end

  describe 'behavior' do
    it 'loads all the weights when opened' do
      input_filtered_search('weight:=', submit: false, extra_space: false)

      expect_filtered_search_dropdown_results(filter_dropdown, 21)
    end
  end
end

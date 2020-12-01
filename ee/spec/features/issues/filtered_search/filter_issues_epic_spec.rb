# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Filter issues by epic', :js do
  include FilteredSearchHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:user) { create(:user) }
  let_it_be(:issue1) { create(:issue, project: project) }
  let_it_be(:issue2) { create(:issue, project: project) }
  let_it_be(:issue3) { create(:issue, project: project) }
  let_it_be(:issue4) { create(:issue, project: project) }
  let_it_be(:epic1) { create(:epic) }
  let_it_be(:epic2) { create(:epic) }
  let_it_be(:epic_issue1) { create(:epic_issue, issue: issue1, epic: epic1) }
  let_it_be(:epic_issue2) { create(:epic_issue, issue: issue2, epic: epic2) }
  let_it_be(:epic_issue3) { create(:epic_issue, issue: issue3, epic: epic2) }

  let(:js_dropdown) { '#js-dropdown-epic' }

  before do
    stub_licensed_features(epics: true)
    stub_feature_flags(vue_issuables_list: false)
    project.add_developer(user)

    sign_in(user)
    visit project_issues_path(project)
  end

  it 'filter issues by epic' do
    input_filtered_search("epic:=&#{epic1.id}")

    expect_issues_list_count(1)
  end

  it 'filter issues not in the epic' do
    input_filtered_search("epic:!=&#{epic1.id}")

    expect_issues_list_count(3)
  end
end

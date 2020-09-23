# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'CodeReviewAnalytics Filtered Search', :js do
  include FilteredSearchHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }

  before do
    stub_licensed_features(code_review_analytics: true)

    project.add_reporter(user)
  end

  context 'when the "new search" feature is disabled' do
    before do
      stub_feature_flags(code_review_analytics_has_new_search: false)

      sign_in(user)

      visit project_analytics_code_reviews_path(project)
    end

    it 'renders the filtered search bar correctly' do
      page.within('.content-wrapper .content .issues-filters') do
        expect(page).to have_css('.filtered-search-box')
      end
    end

    it 'displays label and milestone in search hint' do
      filtered_search.click

      page.within('#js-dropdown-hint') do
        expect(page).to have_content('Label')
        expect(page).to have_content('Milestone')
      end
    end

    context 'with merge_requests' do
      let(:label) { create(:label, title: 'awesome label', project: project) }

      before do
        create(:merge_request, title: "Bug fix-1", source_project: project, source_branch: "branch-1")
        create(:labeled_merge_request, title: "Bug fix with label", source_project: project, source_branch: "branch-with-label", labels: [label])
        create(:labeled_merge_request, title: "Bug fix with label#2", source_project: project, source_branch: "branch-with-label-2", labels: [label])
      end

      it 'filters the list of merge requests', quarantine: 'https://gitlab.com/gitlab-org/gitlab/-/issues/250638' do
        has_merge_requests(3)

        select_label_on_dropdown(label.title)

        has_merge_requests(2)
      end
    end
  end

  context 'when the "new search" feature is enabled' do
    before do
      stub_feature_flags(code_review_analytics_has_new_search: true)

      sign_in(user)

      visit project_analytics_code_reviews_path(project)
    end

    it 'does not render the filtered search bar' do
      page.within('.content-wrapper .content') do
        expect(page).not_to have_css('.issues-filters')
      end
    end
  end

  def has_merge_requests(num = 0)
    expect(page).to have_text("Merge Requests in Review #{num}")
  end
end

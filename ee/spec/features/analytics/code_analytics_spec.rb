# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'CodeReviewAnalytics Filtered Search', :js do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }

  before do
    stub_licensed_features(code_review_analytics: true)

    project.add_reporter(user)

    sign_in(user)

    visit project_analytics_code_reviews_path(project)
  end

  it 'renders the filtered search bar correctly' do
    page.within('.content-wrapper .content .vue-filtered-search-bar-container') do
      expect(page).to have_selector('.gl-search-box-by-click')
      expect(page.find('.gl-filtered-search-term-input')[:placeholder]).to eq('Filter results')
    end
  end

  it 'displays label and milestone in search hint' do
    page.within('.content-wrapper .content .vue-filtered-search-bar-container') do
      page.find('.gl-search-box-by-click').click

      expect(page).to have_selector('.gl-filtered-search-suggestion-list')

      hints = page.find_all('.gl-filtered-search-suggestion-list > li')

      expect(hints.length).to eq(2)
      expect(hints[0]).to have_content('Milestone')
      expect(hints[1]).to have_content('Label')
    end
  end
end

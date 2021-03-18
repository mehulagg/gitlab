# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'CodeReviewAnalytics', :js do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:auditor) { create(:user, auditor: true) }

  before do
    stub_licensed_features(code_review_analytics: true)

    project.add_developer(user)
  end

  context 'filtered search' do
    before do
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

  context 'empty state' do
    it 'shows empty state with "New merge request" button' do
      sign_in(user)

      visit project_analytics_code_reviews_path(project)

      expect(page).to have_content("You don't have any open merge requests")
      expect(page).to have_link('New merge request')
    end

    context 'when signed in user is an Auditor' do
      before do
        sign_in(auditor)

        visit project_analytics_code_reviews_path(project)
      end

      it 'shows empty state without "New merge request" button' do
        expect(page).to have_content("You don't have any open merge requests")
        expect(page).not_to have_link('New merge request')
      end
    end
  end
end

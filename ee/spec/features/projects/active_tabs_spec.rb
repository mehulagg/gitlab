# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Project active tab' do
  let(:user) { create :user }
  let(:project) { create(:project, :repository) }

  def click_tab(title)
    page.within '.sidebar-top-level-items > .active' do
      click_link(title)
    end
  end

  before do
    project.add_maintainer(user)
    sign_in(user)
  end

  context 'on project Analytics/Insights' do
    before do
      stub_licensed_features(insights: true)

      visit project_insights_path(project)
    end

    it_behaves_like 'page has active tab', _('Analytics')
    it_behaves_like 'page has active sub tab', _('Insights')
  end

  context 'on project Analytics/Code Review' do
    before do
      stub_licensed_features(code_review_analytics: true)

      visit project_analytics_code_reviews_path(project)
    end

    it_behaves_like 'page has active tab', _('Analytics')
    it_behaves_like 'page has active sub tab', _('Code Review')
  end
end

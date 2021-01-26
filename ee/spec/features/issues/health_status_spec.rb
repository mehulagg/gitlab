# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Health status' do
  let(:project) { build(:project, :public) }

  before do
    stub_feature_flags(vue_issuables_list: false)
  end

  health_statuses = [
    { name: 'on_track', style: '.status-on-track', text: "On track" },
    { name: 'needs_attention', style: '.status-needs-attention', text: "Needs attention" },
    { name: 'at_risk', style: '.status-at-risk', text: "At risk" }
  ]

  describe 'health status on issue list row' do
    health_statuses.each do |status|
      it "renders health status label for #{status[:name]}" do
        create(:issue, project: project, health_status: status[:name])

        visit project_issues_path(project)

        page.within(first('.issuable-info')) do
          expect(page).to have_selector('[data-testid="health-status"]')
          expect(page).to have_css(status[:style])
          expect(page).to have_content(status[:text])
        end
      end
    end
  end
end

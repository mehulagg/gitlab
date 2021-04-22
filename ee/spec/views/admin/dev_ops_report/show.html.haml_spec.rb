# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'admin/dev_ops_report/show.html.haml' do
  before do
    stub_licensed_features(devops_adoption: true)
  end

  context 'when show_adoption? returns false' do
    before do
      allow(view).to receive(:show_adoption?).and_return(false)
    end

    it 'disables the feature' do
      render

      expect(rendered).not_to have_selector('#devops-adoption')
    end

    it 'shows the timestamp of the latest record' do
      assign(:metric, create(:dev_ops_report_metric, created_at: Time.utc(2012, 5, 1, 14, 30)).present)

      render

      page = Capybara.string(rendered)
      note_node = page.find("div[data-testid='devops-score-note-text']")
      expect(note_node.text).to include('Last updated: 2012-05-01 14:30.')
    end
  end

  context 'when show_adoption? returns true' do
    it 'enables the feature' do
      allow(view).to receive(:show_adoption?).and_return(true)

      render

      expect(rendered).to have_selector('#devops-adoption')
    end
  end
end

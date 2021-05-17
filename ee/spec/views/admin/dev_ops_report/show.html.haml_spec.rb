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

      expect(rendered).not_to have_selector('.js-devops-adoption')
    end
  end

  context 'when show_adoption? returns true' do
    it 'enables the feature' do
      allow(view).to receive(:show_adoption?).and_return(true)

      render

      expect(rendered).to have_selector('.js-devops-adoption')
    end
  end
end

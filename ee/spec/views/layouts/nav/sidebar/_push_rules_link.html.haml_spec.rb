# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'layouts/nav/sidebar/_push_rules_link' do
  context 'license includes source control feature' do
    it 'shows the link' do
      stub_licensed_features(push_rules: true)

      render

      expect(rendered).to have_link 'Source Control'
    end
  end

  context 'license does not include source control feature' do
    it 'hides the link' do
      stub_licensed_features(push_rules: false)

      render

      expect(rendered).not_to have_link 'Source Control'
    end
  end
end

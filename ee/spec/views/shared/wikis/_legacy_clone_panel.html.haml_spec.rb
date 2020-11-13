# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'shared/wikis/_legacy_clone_panel' do
  include EE::GeoHelpers

  let_it_be(:primary) { create(:geo_node, :primary) }
  let_it_be(:secondary) { create(:geo_node) }
  let_it_be(:wiki) { create(:project_wiki) }

  shared_examples 'has no geo-specific instructions' do
    it 'has no geo-specific instructions' do
      render 'shared/wikis/legacy_clone_panel', wiki: wiki

      expect(rendered).not_to match(/See Geo-specific instructions/)
    end
  end

  context 'without Geo enabled' do
    it_behaves_like 'has no geo-specific instructions'
  end

  context 'On a Geo primary node' do
    before do
      stub_current_geo_node(primary)
    end

    it_behaves_like 'has no geo-specific instructions'
  end

  context 'On a Geo secondary node' do
    before do
      stub_current_geo_node(secondary)
    end

    it_behaves_like 'has no geo-specific instructions'
  end
end

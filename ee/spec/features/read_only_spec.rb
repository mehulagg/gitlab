# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Geo read-only message', :geo do
  include ::EE::GeoHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:primary) { create(:geo_node, :primary) }
  let_it_be(:secondary) { create(:geo_node) }

  before do
    sign_in(user)
  end

  it 'shows read-only banner when on a Geo secondary' do
    stub_current_geo_node(secondary)

    visit root_dashboard_path

    expect(page).to have_content('You are on a secondary, read-only Geo node. If you want to make changes, you must visit the primary site.')
    expect(page).to have_content('Go to the primary site')
  end
end

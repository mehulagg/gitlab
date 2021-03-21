# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "projects/environments/show", type: :view do
  before do
    @project = create(:project)
    render
  end

  it 'renders Vue app root when feature flag is enabled' do
    stub_feature_flags(migrate_environment_details_to_vue: true)
    expect(rendered).to have_selector('.js-environment-details')
  end

  it 'does not render the Vue app root when feature flag is disabled' do
    stub_feature_flags(migrate_environment_details_to_vue: false)
    expect(rendered).not_to have_selector('.js-environment-details')
    expect(rendered).to have_selector('#environments-detail-view')
  end
end

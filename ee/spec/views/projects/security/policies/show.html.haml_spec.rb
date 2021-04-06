# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "projects/security/policies/show", type: :view do
  let(:user) { project.owner }
  let(:project) { create(:project) }

  before do
    assign(:project, project)
    stub_feature_flags(security_orchestration_policies_configuration: true)
    stub_licensed_features(security_orchestration_policies: true)
    sign_in(user)
    render
  end

  it 'renders the default state' do
    expect(rendered).to have_selector('h2')
    expect(rendered).to have_selector('h4')
    expect(response).to have_css('input[id=orchestration_policy_project_id]', visible: false)
    expect(rendered).to have_button('Save changes')
  end
end

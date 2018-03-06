require 'spec_helper'

describe 'Project settings > [EE] repository' do
  include ExternalAuthorizationServiceHelpers

  let(:user) { create(:user) }
  let(:project) { create(:project_empty_repo) }

  before do
    project.add_master(user)
    sign_in(user)
  end

  it 'shows the field to set a classification label when the feature is enabled' do
    external_service_allow_access(user, project)

    visit edit_project_path(project)

    expect(page).to have_selector('#project_external_authorization_classification_label')
  end

  it 'shows the field to set a classification label when the feature is unavailable' do
    stub_licensed_features(external_authorization_service: false)

    visit edit_project_path(project)

    expect(page).not_to have_selector('#project_external_authorization_classification_label')
  end
end

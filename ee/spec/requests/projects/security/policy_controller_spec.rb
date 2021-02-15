# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Security::PolicyController, type: :request do
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user) }

  before do
    project.add_developer(user)
    stub_feature_flags(security_orchestration_policies_configuration: true)
    stub_licensed_features(security_orchestration_policies: true)
    login_as(user)
  end

  context 'feature available' do
    it 'can access page' do
      get path

      expect(response).to have_gitlab_http_status(:ok)
    end
  end
end

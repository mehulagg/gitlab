# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::ComplianceFrameworksController do
  let(:group) { create(:group) }
  let(:user)  { create(:user) }

  before do
    sign_in(user)
  end

  context 'when compliance frameworks feature is disabled' do
    before do
      stub_feature_flags(ff_custom_compliance_frameworks: false)
      stub_licensed_features(custom_compliance_frameworks: false)
    end

    it 'returns 404 not found when requesting GET #new' do
      get :new, params: { group_id: group }

      expect(response).to have_gitlab_http_status(:not_found)
    end
  end

  context 'when compliance frameworks feature is enabled' do
    before do
      stub_feature_flags(ff_custom_compliance_frameworks: true)
      stub_licensed_features(custom_compliance_frameworks: true)
    end

    describe 'GET #new' do
      it 'renders template' do
        group.add_owner(user)
        get :new, params: { group_id: group }

        expect(response).to render_template 'groups/compliance_frameworks/new'
      end

      context 'with unauthorized user' do
        it 'returns 404 not found' do
          get :new, params: { group_id: group }

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::Geo::NodesBetaController do
  include AdminModeHelper

  let_it_be(:admin) { create(:admin) }

  before do
    enable_admin_mode!(admin)
    login_as(admin)
  end

  describe 'GET /geo/nodes_beta' do
    context 'with a valid license' do
      before do
        stub_licensed_features(geo: true)
      end

      context 'with :geo_nodes_beta feature enabled' do
        before do
          stub_feature_flags(geo_nodes_beta: true)
        end

        it 'renders the Geo Nodes Beta View', :aggregate_failures do
          get admin_geo_nodes_beta_path

          expect(response).to render_template(:index)
          expect(response.body).to include('Geo Nodes Beta')
        end
      end

      context 'with :geo_nodes_beta feature disabled' do
        before do
          stub_feature_flags(geo_nodes_beta: false)
        end

        it 'redirects to Geo Nodes View' do
          get admin_geo_nodes_beta_path

          expect(response).to redirect_to(admin_geo_nodes_path)
        end
      end
    end

    context 'without a valid license' do
      before do
        stub_licensed_features(geo: false)
      end

      it 'returns a 403' do
        get admin_geo_nodes_beta_path

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end
  end
end

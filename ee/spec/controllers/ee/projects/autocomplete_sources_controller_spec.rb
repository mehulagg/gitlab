# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Projects::AutocompleteSourcesController do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:group2) { create(:group) }
  let_it_be(:project) { create(:project, :public, group: group) }
  let_it_be(:epic) { create(:epic, group: group) }
  let_it_be(:epic2) { create(:epic, group: group2) }

  before do
    sign_in(user)
  end

  context 'when epics feature is disabled' do
    it 'returns 404 status' do
      get :epics, params: { namespace_id: project.namespace, project_id: project }

      expect(response).to have_gitlab_http_status(:not_found)
    end
  end

  context 'when epics feature is enabled' do
    before do
      stub_licensed_features(epics: true)
    end

    describe '#epics' do
      it 'returns the correct response' do
        get :epics, params: { namespace_id: project.namespace, project_id: project }

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response).to be_an(Array)
        expect(json_response.count).to eq(1)
        expect(json_response.first).to include(
          'iid' => epic.iid, 'title' => epic.title
        )
      end
    end
  end
end

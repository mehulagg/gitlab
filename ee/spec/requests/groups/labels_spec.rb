# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'view audit events' do
  describe 'GET /groups/:group/-/audit_events' do
    let_it_be(:group) { create(:group, :public) }
    let_it_be(:group1) { create(:group, parent: group) }

    it 'returns 200 response' do
      send_request

      expect(response).to have_gitlab_http_status(:ok)
    end

    it 'avoids N+1 DB queries', :request_store do
      control = ActiveRecord::QueryRecorder.new(skip_cached: false) { send_request }

      create_list(:group, 3, parent: group)

      expect { send_request }.not_to exceed_all_query_limit(control)
    end

    context 'when preset_root_ancestor_for_labels flag is disabled' do
      before do
        stub_feature_flags(preset_root_ancestor_for_labels: false)
      end

      it 'does additional N+1 DB queries', :request_store do
        control = ActiveRecord::QueryRecorder.new(skip_cached: false) { send_request }

        create_list(:group, 3, parent: group)

        expect { send_request }.to exceed_all_query_limit(control)
      end
    end

    def send_request
      get group_labels_path(group, include_descendant_groups: true, format: :json)
    end
  end
end

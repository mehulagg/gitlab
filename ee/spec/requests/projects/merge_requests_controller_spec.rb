# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::MergeRequestsController do
  let(:merge_request) { create(:merge_request) }
  let(:project) { merge_request.project }
  let(:user) { merge_request.author }

  before do
    login_as(user)
  end

  describe 'GET #edit' do
    def get_edit
      get edit_project_merge_request_path(project, merge_request)
    end

    context 'when the project requires code owner approval' do
      before do
        stub_licensed_features(code_owners: true, code_owner_approval_required: true)

        get_edit # Warm the cache
      end

      it 'does not cause an extra queries when code owner rules are present' do
        control = ActiveRecord::QueryRecorder.new { get_edit }

        create(:code_owner_rule, merge_request: merge_request)

        # Threshold of 3 because we load the source_rule, users & group users for all rules
        expect { get_edit }.not_to exceed_query_limit(control).with_threshold(3)
      end

      it 'does not cause extra queries when multiple code owner rules are present' do
        create(:code_owner_rule, merge_request: merge_request)

        control = ActiveRecord::QueryRecorder.new { get_edit }

        create(:code_owner_rule, merge_request: merge_request)

        expect { get_edit }.not_to exceed_query_limit(control)
      end
    end
  end
end

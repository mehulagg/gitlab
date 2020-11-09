# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Analytics (JavaScript fixtures)', :sidekiq_inline do
  include JavaScriptFixturesHelpers

  let(:group) { create(:group) }
  let(:project) { create(:project, :repository, namespace: group) }
  let(:user) { create(:user, :admin) }

  around do |example|
    Timecop.freeze { example.run }
  end

  before(:all) do
    clean_frontend_fixtures('analytics/charts/')
  end

  describe Groups::Analytics::TasksByTypeController, type: :controller do
    render_views

    let(:label) { create(:group_label, group: group) }
    let(:label2) { create(:group_label, group: group) }
    let(:label3) { create(:group_label, group: group) }

    before do
      5.times do |i|
        create(:labeled_issue, created_at: i.days.ago, project: create(:project, group: group), labels: [label])
        create(:labeled_issue, created_at: i.days.ago, project: create(:project, group: group), labels: [label2])
        create(:labeled_issue, created_at: i.days.ago, project: create(:project, group: group), labels: [label3])
      end

      stub_licensed_features(type_of_work_analytics: true)

      group.add_maintainer(user)

      sign_in(user)
    end

    it 'analytics/charts/type_of_work/tasks_by_type.json' do
      params = { group_id: group.full_path, label_ids: [label.id, label2.id, label3.id], created_after: 10.days.ago, subject: 'Issue' }

      get(:show, params: params, format: :json)

      expect(response).to be_successful
    end
  end
end

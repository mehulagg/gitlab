# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elasticsearch::Model::Adapter::ActiveRecord::Records, :elastic do
  describe '#records' do
    let(:user) { create(:user) }
    let(:search_options) { { options: { current_user: user, project_ids: :any, order_by: 'created_at', sort: 'desc' } } }

    before do
      stub_ee_application_setting(elasticsearch_indexing: true)

      @new_issue = create(:issue)
      @recent_issue = create(:issue, created_at: 1.hour.ago)
      @old_issue = create(:issue, created_at: 7.days.ago)

      ensure_elasticsearch_index!
    end

    it 'returns results in the same sorted order as they come back from Elasticsearch' do
      expect(Issue.elastic_search('*', **search_options).records.to_a).to eq([
        @new_issue,
        @recent_issue,
        @old_issue
      ])
    end
  end
end

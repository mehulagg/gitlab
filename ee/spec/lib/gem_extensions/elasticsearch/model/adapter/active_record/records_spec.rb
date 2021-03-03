# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elasticsearch::Model::Adapter::ActiveRecord::Records, :elastic do
  before do
    stub_ee_application_setting(elasticsearch_indexing: true)
  end

  describe '#records' do
    let(:user) { create(:user) }
    let(:search_options) { { options: { current_user: user, project_ids: :any, order_by: 'created_at', sort: 'desc' } } }
    let(:results) { Issue.elastic_search('*', **search_options).records.to_a }

    let!(:new_issue) { create(:issue) }
    let!(:recent_issue) { create(:issue, created_at: 1.hour.ago) }
    let!(:old_issue) { create(:issue, created_at: 7.days.ago) }

    it 'returns results in the same sorted order as they come back from Elasticsearch' do
      ensure_elasticsearch_index!

      expect(results).to eq([new_issue, recent_issue, old_issue])
    end
  end
end

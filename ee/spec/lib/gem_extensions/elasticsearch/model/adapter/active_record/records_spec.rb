# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elasticsearch::Model::Adapter::ActiveRecord::Records, :elastic do
  describe '#records' do
    let(:user) { create(:user) }
    let(:search_options) { { options: { current_user: user, project_ids: :any } } }

    before do
      stub_ee_application_setting(elasticsearch_indexing: true)

      @middle_relevant = create(
        :issue,
        title: 'Sorting could improve', # Some keywords in title
        description: 'I think you could make it better'
      )
      @least_relevant = create(
        :issue,
        title: 'I love GitLab', # No keywords in title
        description: 'There is so much to love! For example, you could not possibly make sorting any better'
      )

      @most_relevant = create(
        :issue,
        title: 'Make sorting better', # All keywords in title
        description: 'This issue is here to make the sorting better'
      )

      ensure_elasticsearch_index!
    end

    it 'returns results in the same sorted order as they come back from Elasticsearch' do
      expect(Issue.elastic_search('make sorting better', **search_options).records.to_a).to eq([
        @most_relevant,
        @middle_relevant,
        @least_relevant
      ])
    end
  end
end

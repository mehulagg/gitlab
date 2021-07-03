# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::Latest::GitClassProxy, :elastic do
  let_it_be(:project) { create(:project, :repository) }

  let(:included_class) { Elastic::Latest::RepositoryClassProxy }

  subject { included_class.new(project.repository) }

  describe '#elastic_search_as_found_blob' do
    before do
      stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)

      Gitlab::Elastic::Indexer.new(project).run
      ensure_elasticsearch_index!
    end

    it 'returns FoundBlob', :sidekiq_inline do
      results = subject.elastic_search_as_found_blob('def popen')

      expect(results).not_to be_empty
      expect(results).to all(be_a(Gitlab::Search::FoundBlob))

      result = results.first

      expect(result.ref).to eq('b83d6e391c22777fca1ed3012fce84f633d7fed0')
      expect(result.path).to eq('files/ruby/popen.rb')
      expect(result.startline).to eq(2)
      expect(result.data).to include('Popen')
      expect(result.project).to eq(project)
    end
  end

  it "names elasticsearch queries" do
    subject.elastic_search_as_found_blob('*')

    assert_named_queries('doc:is_a:blob',
                         'blob:match:search_terms')
  end
end

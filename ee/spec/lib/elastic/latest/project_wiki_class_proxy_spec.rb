# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::Latest::ProjectWikiClassProxy do
  let_it_be(:project) { create(:project, :wiki_repo) }

  subject { described_class.new(project.wiki.repository) }

  describe '#elastic_search_as_wiki_page', :elastic do
    let_it_be(:page) { create(:wiki_page, wiki: project.wiki) }

    before do
      stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)

      Gitlab::Elastic::Indexer.new(project, wiki: true).run
      ensure_elasticsearch_index!
    end

    it 'returns FoundWikiPage', :sidekiq_inline do
      results = subject.elastic_search_as_wiki_page('*')

      expect(results.size).to eq(1)
      expect(results).to all(be_a(Gitlab::Search::FoundWikiPage))

      result = results.first

      expect(result.path).to eq(page.path)
      expect(result.startline).to eq(1)
      expect(result.data).to include(page.content)
      expect(result.project).to eq(project)
    end
  end
end

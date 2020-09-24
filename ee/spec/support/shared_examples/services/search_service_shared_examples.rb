# frozen_string_literal: true

RSpec.shared_examples 'EE search service shared examples' do |normal_results, elasticsearch_results|
  let(:params) { { search: '*' } }

  describe '#use_elasticsearch?' do
    it 'delegates to Gitlab::CurrentSettings.search_using_elasticsearch?' do
      expect(Gitlab::CurrentSettings)
        .to receive(:search_using_elasticsearch?)
        .with(scope: scope)
        .and_return(:value)

      expect(service.use_elasticsearch?).to eq(:value)
    end

    context 'when requesting basic_search' do
      let(:params) { { search: '*', basic_search: 'true' } }

      it 'returns false' do
        expect(Gitlab::CurrentSettings)
          .not_to receive(:search_using_elasticsearch?)

        expect(service.use_elasticsearch?).to eq(false)
      end
    end
  end

  describe '#execute' do
    subject { service.execute }

    it 'returns an Elastic result object when elasticsearch is enabled' do
      expect(Gitlab::CurrentSettings)
        .to receive(:search_using_elasticsearch?)
        .with(scope: scope)
        .and_return(true)

      is_expected.to be_a(elasticsearch_results)
    end

    it 'returns an ordinary result object when elasticsearch is disabled' do
      expect(Gitlab::CurrentSettings)
        .to receive(:search_using_elasticsearch?)
        .with(scope: scope)
        .and_return(false)

      is_expected.to be_a(normal_results)
    end

    context 'advanced syntax queries for all scopes', :elastic, :sidekiq_inline do
      queries = [
        '"display bug"',
        'bug -display',
        'bug display | sound',
        'bug | (display +sound)',
        'bug find_by_*',
        'argument \-last'
      ]

      scopes = if elasticsearch_results == ::Gitlab::Elastic::SnippetSearchResults
                 %w[
                   snippet_titles
                 ]
               else
                 %w[
                   merge_requests
                   notes
                   commits
                   blobs
                   projects
                   issues
                   wiki_blobs
                   milestones
                 ]
               end

      queries.each do |query|
        scopes.each do |scope|
          context "with query #{query} and scope #{scope}" do
            let(:params) { { search: query, scope: scope } }

            it "allows advanced query" do
              allow(Gitlab::CurrentSettings)
                .to receive(:search_using_elasticsearch?)
                .and_return(true)

              ensure_elasticsearch_index!

              results = subject
              expect(results.objects(scope)).to be_kind_of(Enumerable)
            end
          end
        end
      end
    end
  end
end

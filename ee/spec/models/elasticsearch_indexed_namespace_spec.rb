# frozen_string_literal: true

require 'spec_helper'

describe ElasticsearchIndexedNamespace do
  before do
    stub_ee_application_setting(elasticsearch_indexing: true)
  end

  describe 'scope' do
    describe '.namespace_in' do
      let(:records) { create_list(:elasticsearch_indexed_namespace, 3) }

      it 'returns records of the ids' do
        expect(described_class.namespace_in(records.last(2).map(&:id))).to eq(records.last(2))
      end
    end
  end

  it_behaves_like 'an elasticsearch indexed container' do
    let(:container) { :elasticsearch_indexed_namespace }
    let(:attribute) { :namespace_id }
    let(:index_action) do
      expect(ElasticNamespaceIndexerWorker).to receive(:perform_async).with(subject.namespace_id, :index)
    end
    let(:delete_action) do
      expect(ElasticNamespaceIndexerWorker).to receive(:perform_async).with(subject.namespace_id, :delete)
    end
  end

  context 'caching' do
    it 'invalidates indexed project cache' do
      expect(ElasticsearchIndexedProject).to receive(:drop_limited_ids_cache!).and_call_original.twice
      expect(ElasticsearchIndexedNamespace).to receive(:drop_limited_ids_cache!).and_call_original.twice

      n = create(:elasticsearch_indexed_namespace)

      n.destroy
    end
  end

  context 'with plans', :use_clean_rails_redis_caching do
    Plan::PAID_HOSTED_PLANS.each do |plan|
      plan_factory = "#{plan}_plan"
      let_it_be(plan_factory) { create(plan_factory) }
    end

    let_it_be(:namespaces) { create_list(:namespace, 3) }
    let_it_be(:subscription1) { create(:gitlab_subscription, namespace: namespaces[2]) }
    let_it_be(:subscription2) { create(:gitlab_subscription, namespace: namespaces[0]) }
    let_it_be(:subscription3) { create(:gitlab_subscription, :silver, namespace: namespaces[1]) }

    before do
      stub_ee_application_setting(elasticsearch_indexing: false)
    end

    def expect_indexed_namespaces_to_match(array)
      ids = described_class.order(:created_at).pluck(:namespace_id)

      expect(ids).to eq(array)
      expect(ids).to match_array(described_class.limited_ids_cached)
    end

    def expect_queue_to_contain(*args)
      expect(ElasticNamespaceIndexerWorker.jobs).to include(
        hash_including("args" => args)
      )
    end

    describe '.index_first_n_namespaces_of_plan' do
      it 'creates records, scoped by plan and ordered by namespace id' do
        expect(ElasticsearchIndexedNamespace).to receive(:drop_limited_ids_cache!).and_call_original.exactly(3).times

        ids = namespaces.map(&:id)

        described_class.index_first_n_namespaces_of_plan('gold', 1)

        expect_indexed_namespaces_to_match([ids[0]])
        expect_queue_to_contain(ids[0], "index")

        described_class.index_first_n_namespaces_of_plan('gold', 2)

        expect_indexed_namespaces_to_match([ids[0], ids[2]])
        expect_queue_to_contain(ids[2], "index")

        described_class.index_first_n_namespaces_of_plan('silver', 1)

        expect_indexed_namespaces_to_match([ids[0], ids[2], ids[1]])
        expect_queue_to_contain(ids[1], "index")
      end
    end

    describe '.unindex_last_n_namespaces_of_plan' do
      before do
        described_class.index_first_n_namespaces_of_plan('gold', 2)
        described_class.index_first_n_namespaces_of_plan('silver', 1)
      end

      it 'creates records, scoped by plan and ordered by namespace id' do
        expect(ElasticsearchIndexedNamespace).to receive(:drop_limited_ids_cache!).and_call_original.exactly(3).times

        ids = namespaces.map(&:id)

        expect_indexed_namespaces_to_match([ids[0], ids[2], ids[1]])

        described_class.unindex_last_n_namespaces_of_plan('gold', 1)

        expect_indexed_namespaces_to_match([ids[0], ids[1]])
        expect_queue_to_contain(ids[2], "delete")

        described_class.unindex_last_n_namespaces_of_plan('silver', 1)

        expect_indexed_namespaces_to_match([ids[0]])

        expect_queue_to_contain(ids[1], "delete")

        described_class.unindex_last_n_namespaces_of_plan('gold', 1)

        expect_indexed_namespaces_to_match([])
        expect_queue_to_contain(ids[0], "delete")
      end
    end
  end
end

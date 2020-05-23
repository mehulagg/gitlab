# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Graphql::Pagination::FilterableArrayConnection do
  let(:callback) { proc { |nodes| nodes } }
  let(:all_nodes) { Gitlab::Graphql::FilterableArray.new(callback, 1, 2, 3, 4, 5) }
  let(:arguments) { {} }

  subject(:connection) do
    described_class.new(all_nodes, { max_page_size: 3 }.merge(arguments))
  end

  describe '#nodes' do
    let(:paged_nodes) { subject.nodes }

    it_behaves_like 'connection with paged nodes' do
      let(:paged_nodes_size) { 3 }
    end

    context 'when callback filters some nodes' do
      let(:callback) { proc { |nodes| nodes[1..-1] } }

      it 'does not return filtered elements' do
        expect(subject.nodes).to contain_exactly(all_nodes[1], all_nodes[2])
      end
    end
  end
end

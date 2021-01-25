# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Graphql::Aggregations::Issues::LazyBlockAggregate do
  let(:query_ctx) do
    {}
  end

  let(:issue_id) { 37 }
  let(:blocks_issue_id) { 18 }
  let(:blocking_issue_id) { 38 }

  describe '#initialize' do
    it 'adds the issue_id to the lazy state' do
      subject = described_class.new(query_ctx, issue_id)

      expect(subject.lazy_state[:pending_ids]).to match [issue_id]
      expect(subject.issue_id).to match issue_id
    end

    describe 'load_issue_objects' do
      subject { described_class.new(query_ctx, issue_id) }

      it 'is false by default' do
        expect(subject.lazy_state[:load_issue_objects]).to eq false
      end

      context 'when provided' do
        using RSpec::Parameterized::TableSyntax

        subject { described_class.new(query_ctx, issue_id, load_issue_objects: load_issue_objects) }

        where(:value, :result) do
          true       | true
          false      | false
          nil        | false
          "nonsense" | true
        end

        with_them do
          let(:load_issue_objects) { value }

          specify do
            expect(subject.lazy_state[:load_issue_objects]).to eq result
          end
        end
      end

      it 'adds load_issue_objects to the lazy state' do
        expect(subject.lazy_state[:pending_ids]).to match [issue_id]
        expect(subject.issue_id).to match issue_id
      end
    end
  end

  describe '#block_aggregate' do
    subject { described_class.new(query_ctx, issue_id) }
    let(:query_ctx) do
      { lazy_state: fake_state }
    end

    # We cannot directly stub IssueLink, otherwise we get a strange RSpec error
    let(:issue_link_klass) { class_double('IssueLink').as_stubbed_const }
    let(:fake_state) do
      { pending_ids: Set.new, loaded_objects: {issue_id: double} }
    end

    before do
      subject.instance_variable_set(:@lazy_state, fake_state)
    end

    context 'when there is a block provided' do
      subject do
        described_class.new(query_ctx, issue_id) do |result|
          result.do_thing
        end
      end

      it 'calls the block' do
        expect(fake_state[:loaded_objects][issue_id]).to receive(:do_thing)

        subject.block_aggregate
      end
    end

    context 'if the record has already been loaded' do
      let(:fake_state) do
        { pending_ids: Set.new, loaded_objects: { issue_id => double(count: 10) } }
      end

      it 'does not make the query again' do
        expect(issue_link_klass).not_to receive(:blocked_issues_for_collection)

        subject.block_aggregate
      end
    end

    context 'if the record has not been loaded' do
      let(:other_issue_id) { 39 }
      let(:fake_state) do
        { pending_ids: Set.new([issue_id]), load_issue_objects: load_issue_objects, loaded_objects: {} }
      end
      let(:fake_links) do
        [
            double(target_id: issue_id, source_id: 2)
        ]
      end

      shared_examples 'clears the pending IDs' do
        specify do
          expect(subject.lazy_state[:pending_ids]).to be_empty
        end
      end

      context 'when load_issue_objects has been set in the lazy state' do
        let(:load_issue_objects) { true }
        let(:fake_blocking_issue) { build(:issue) }
        let(:fake_data) { [fake_link] }

        before do
          expect(issue_link_klass).to receive(:blocking_issue_ids).and_return(fake_links)
          expect_next_instance_of(IssuesFinder) do |finder|
            expect(finder).to receive_message_chain("execute.where").and_return([fake_blocking_issue])
          end
          subject.block_aggregate
        end

        it 'loads all the issue objects under :issues' do
          ap loaded_objects
          expect(loaded_objects[:issues]).to match [fake_blocking_issue]
          expect(loaded_objects[:count]).to be_nil
        end

        it_behaves_like 'clears the pending IDs'
      end

      context 'when load_issue_objects has NOT been set' do
        let(:load_issue_objects) { nil }
        let(:fake_count) { 1.0 }
        let(:fake_data) do
          [
              double(blocked_issue_id: issue_id, count: fake_count),
              nil # nil for unblocked issues
          ]
        end

        before do
          expect(issue_link_klass).to receive(:blocked_issues_for_collection).and_return(fake_data)
          subject.block_aggregate
        end

        it 'loads only the counts under :count', :aggregate_failures do
          expect(loaded_objects[issue_id][:issues]).to be_nil
          expect(loaded_objects[issue_id][:count]).to eq fake_count
        end

        it_behaves_like 'clears the pending IDs'
      end
    end
  end

  def loaded_objects
    subject.lazy_state[:loaded_objects]
  end
end

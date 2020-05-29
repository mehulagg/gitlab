# frozen_string_literal: true

require 'spec_helper'

describe ResourceMilestoneEvent, type: :model do
  it_behaves_like 'a resource event'
  it_behaves_like 'a resource event for issues'
  it_behaves_like 'a resource event for merge requests'

  it_behaves_like 'having unique enum values'

  describe 'associations' do
    it { is_expected.to belong_to(:milestone) }
  end

  describe 'validations' do
    context 'when issue and merge_request are both nil' do
      subject { build(described_class.name.underscore.to_sym, issue: nil, merge_request: nil) }

      it { is_expected.not_to be_valid }
    end

    context 'when issue and merge_request are both set' do
      subject { build(described_class.name.underscore.to_sym, issue: build(:issue), merge_request: build(:merge_request)) }

      it { is_expected.not_to be_valid }
    end

    context 'when issue is set' do
      subject { create(described_class.name.underscore.to_sym, issue: create(:issue), merge_request: nil) }

      it { is_expected.to be_valid }
    end

    context 'when merge_request is set' do
      subject { create(described_class.name.underscore.to_sym, issue: nil, merge_request: create(:merge_request)) }

      it { is_expected.to be_valid }
    end
  end

  describe 'states' do
    [Issue, MergeRequest].each do |klass|
      klass.available_states.each do |state|
        it "supports state #{state.first} for #{klass.name.underscore}" do
          model = create(klass.name.underscore, state: state[0])
          key = model.class.name.underscore
          event = build(described_class.name.underscore.to_sym, key => model, state: model.state)

          expect(event.state).to eq(state[0])
        end
      end
    end
  end

  shared_examples 'a milestone action queryable resource event' do |expected_results_for_actions|
    [Issue, MergeRequest].each do |klass|
      expected_results_for_actions.each do |action, expected_result|
        it "is #{expected_result} for action #{action} on #{klass.name.underscore}" do
          model = create(klass.name.underscore)
          key = model.class.name.underscore
          event = build(described_class.name.underscore.to_sym, key => model, action: action)

          expect(event.send(query_method)).to eq(expected_result)
        end
      end
    end
  end

  describe '#added?' do
    it_behaves_like 'a milestone action queryable resource event', { add: true, remove: false } do
      let(:query_method) { :add? }
    end
  end

  describe '#removed?' do
    it_behaves_like 'a milestone action queryable resource event', { add: false, remove: true } do
      let(:query_method) { :remove? }
    end
  end

  describe '#milestone_title' do
    let(:milestone) { create(:milestone, title: 'v2.3') }
    let(:event) { create(:resource_milestone_event, milestone: milestone) }

    it 'returns the expected title' do
      expect(event.milestone_title).to eq('v2.3')
    end

    context 'when milestone is nil' do
      let(:event) { create(:resource_milestone_event, milestone: nil) }

      it 'returns nil' do
        expect(event.milestone_title).to be_nil
      end
    end
  end

  describe '#milestone_parent' do
    let_it_be(:project) { create(:project) }
    let_it_be(:group) { create(:group) }

    let(:milestone) { create(:milestone, project: project) }
    let(:event) { create(:resource_milestone_event, milestone: milestone) }

    context 'when milestone parent is project' do
      it 'returns the expected parent' do
        expect(event.milestone_parent).to eq(project)
      end
    end

    context 'when milestone parent is group' do
      let(:milestone) { create(:milestone, group: group) }

      it 'returns the expected parent' do
        expect(event.milestone_parent).to eq(group)
      end
    end

    context 'when milestone is nil' do
      let(:event) { create(:resource_milestone_event, milestone: nil) }

      it 'returns nil' do
        expect(event.milestone_parent).to be_nil
      end
    end
  end
end

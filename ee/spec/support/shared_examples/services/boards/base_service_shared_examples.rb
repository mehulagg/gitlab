# frozen_string_literal: true

RSpec.shared_examples 'setting a milestone scope' do
  before do
    stub_licensed_features(scoped_issue_board: true)
  end

  shared_examples 'an invalid milestone' do
    context 'when milestone is from another project / group' do
      let(:milestone) { create(:milestone) }

      it { expect(subject.milestone).to be_nil }
    end
  end

  shared_examples 'a predefined milestone' do
    context 'Upcoming' do
      let(:milestone) { ::Milestone::Upcoming }

      it { expect(subject.milestone).to eq(milestone) }
    end

    context 'Started' do
      let(:milestone) { ::Milestone::Started }

      it { expect(subject.milestone).to eq(milestone) }
    end
  end

  shared_examples 'a group milestone' do
    context 'when milestone is a group milestone' do
      let(:milestone) { create(:milestone, group: group) }

      it { expect(subject.milestone).to eq(milestone) }
    end

    context 'when milestone is an an ancestor group milestone' do
      let(:milestone) { create(:milestone, group: ancestor_group) }

      it { expect(subject.milestone).to eq(milestone) }
    end
  end

  let(:ancestor_group) { create(:group) }
  let(:group) { create(:group, parent: ancestor_group) }

  context 'for a group board' do
    let(:parent) { group }

    it_behaves_like 'an invalid milestone'
    it_behaves_like 'a predefined milestone'
    it_behaves_like 'a group milestone'
  end

  context 'for a project board' do
    let(:project) { create(:project, :private, group: group) }
    let(:parent) { project }

    it_behaves_like 'an invalid milestone'
    it_behaves_like 'a predefined milestone'
    it_behaves_like 'a group milestone'

    context 'when milestone is a project milestone' do
      let(:milestone) { create(:milestone, project: project) }

      it { expect(subject.milestone).to eq(milestone) }
    end
  end
end

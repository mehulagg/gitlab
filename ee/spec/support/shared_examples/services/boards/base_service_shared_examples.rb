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

RSpec.shared_examples 'setting an iteration scope' do
  before do
    stub_licensed_features(scoped_issue_board: true)
  end

  shared_examples 'an invalid iteration' do
    context 'when iteration is from another group' do
      let(:iteration) { create(:iteration, group: create(:group)) }

      it { expect(subject.iteration).to be_nil }
    end
  end

  shared_examples 'a predefined iteration' do
    context 'None' do
      let(:iteration) { ::Iteration::Constants::None }

      it { expect(subject.iteration).to eq(iteration) }
    end

    context 'Any' do
      let(:iteration) { ::Iteration::Constants::Any }

      it { expect(subject.iteration).to be_nil }
    end

    context 'Current' do
      let(:iteration) { ::Iteration::Constants::Current }

      it { expect(subject.iteration).to eq(iteration) }
    end
  end

  shared_examples 'a group iteration' do
    context 'when iteration is in current group' do
      let(:iteration) { create(:iteration, group: group) }

      it { expect(subject.iteration).to eq(iteration) }
    end

    context 'when iteration is in an ancestor group' do
      let(:iteration) { create(:iteration, group: ancestor_group) }

      it { expect(subject.iteration).to eq(iteration) }
    end
  end

  let(:ancestor_group) { create(:group) }
  let(:group) { create(:group, parent: ancestor_group) }

  context 'for a group board' do
    let(:parent) { group }

    it_behaves_like 'an invalid iteration'
    it_behaves_like 'a predefined iteration'
    it_behaves_like 'a group iteration'
  end

  context 'for a project board' do
    let(:project) { create(:project, :private, group: group) }
    let(:parent) { project }

    it_behaves_like 'an invalid iteration'
    it_behaves_like 'a predefined iteration'
    it_behaves_like 'a group iteration'
  end
end

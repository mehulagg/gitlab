# frozen_string_literal: true

RSpec.shared_examples 'setting a timebox scope' do |timebox_type|
  before do
    stub_licensed_features(scoped_issue_board: true)
  end

  shared_examples "an invalid #{timebox_type}" do
    context "when #{timebox_type} is from another project / group" do
      let(timebox_type) { create(timebox_type.to_sym) } # rubocop:disable Rails/SaveBang

      it { expect(subject.try(timebox_type)).to be_nil }
    end
  end

  shared_examples "a group #{timebox_type}" do
    context "when #{timebox_type} is in current group" do
      let(timebox_type) { create(timebox_type.to_sym, group: group) }

      it { expect(subject.try(timebox_type)).to eq(try(timebox_type)) }
    end

    context "when #{timebox_type} is in an ancestor group" do
      let(timebox_type) { create(timebox_type.to_sym, group: ancestor_group) }

      it { expect(subject.try(timebox_type)).to eq(try(timebox_type)) }
    end
  end

  let(:ancestor_group) { create(:group) }
  let(:group) { create(:group, parent: ancestor_group) }

  context 'for a group board' do
    let(:parent) { group }

    it_behaves_like "an invalid #{timebox_type}"
    it_behaves_like "a predefined #{timebox_type}"
    it_behaves_like "a group #{timebox_type}"
  end

  context 'for a project board' do
    let(:project) { create(:project, :private, group: group) }
    let(:parent) { project }

    it_behaves_like "an invalid #{timebox_type}"
    it_behaves_like "a predefined #{timebox_type}"
    it_behaves_like "a group #{timebox_type}"

    if timebox_type.to_sym == :milestone
      context 'when milestone is a project milestone' do
        let(:milestone) { create(:milestone, project: project) }

        it { expect(subject.milestone).to eq(milestone) }
      end
    end
  end
end

RSpec.shared_examples 'setting a milestone scope' do
  shared_examples "a predefined milestone" do
    context 'None' do
      let(:milestone) { ::Milestone::None }

      it { expect(subject.milestone).to eq(milestone) }
    end

    context 'Any' do
      let(:milestone) { ::Milestone::Any }

      it { expect(subject.milestone).to eq(milestone) }
    end

    context 'Upcoming' do
      let(:milestone) { ::Milestone::Upcoming }

      it { expect(subject.milestone).to eq(milestone) }
    end

    context 'Started' do
      let(:milestone) { ::Milestone::Started }

      it { expect(subject.milestone).to eq(milestone) }
    end
  end

  it_behaves_like 'setting a timebox scope', :milestone
end

RSpec.shared_examples 'setting an iteration scope' do
  shared_examples 'a predefined iteration' do
    context 'None' do
      let(:iteration) { ::Iteration::Predefined::None }

      it { expect(subject.iteration).to eq(iteration) }
    end

    context 'Any' do
      let(:iteration) { ::Iteration::Predefined::Any }

      it { expect(subject.iteration).to eq(iteration) }
    end

    context 'Current' do
      let(:iteration) { ::Iteration::Predefined::Current }

      it { expect(subject.iteration).to eq(iteration) }
    end
  end

  it_behaves_like 'setting a timebox scope', :iteration
end

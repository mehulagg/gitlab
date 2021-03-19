# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ImportExport::Group::GroupAndDescendantsRepoSaver do
  let_it_be(:group) { create(:group) }
  let_it_be(:subgroup) { create(:group, parent: group) }

  let(:shared) { Gitlab::ImportExport::Shared.new(group) }

  subject { described_class.new(group: group, shared: shared) }

  it 'exports the group and subgroups wiki repo' do
    expect_next_instance_of(Gitlab::ImportExport::WikiRepoSaver, exportable: group, shared: shared) do |saver|
      expect(saver).to receive(:save).and_return(true)
    end

    expect_next_instance_of(Gitlab::ImportExport::WikiRepoSaver, exportable: subgroup, shared: shared) do |saver|
      expect(saver).to receive(:save).and_return(true)
    end

    expect(subject.save).to eq true
  end

  context 'if any of the wiki exports fails' do
    it 'returns false and stops exporting other groups' do
      expect_next_instance_of(Gitlab::ImportExport::WikiRepoSaver, exportable: group, shared: shared) do |saver|
        expect(saver).to receive(:save).and_return(false)
      end

      expect(Gitlab::ImportExport::WikiRepoSaver).not_to receive(:new).with(exportable: subgroup, shared: shared)

      expect(subject.save).to eq false
    end
  end
end

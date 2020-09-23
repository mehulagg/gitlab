# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::UsersFinder do
  describe '#execute' do
    subject { described_class.new(board) }

    context 'when parent is a project' do
      let(:project) { create(:project) }
      let(:board) { create(:board, project: project) }

      it 'requests correct relations' do
        expect_next_instance_of(MembersFinder) do |instance|
          expect(instance).to receive(:execute).with(include_relations: [:direct, :descendants, :inherited]).and_call_original
        end

        subject.execute
      end

      it 'finds ProjectMembers with MemberFinder' do
        results = subject.execute

        expect(subject.instance_variable_get(:@finder_service)).to be_kind_of(MembersFinder)
        expect(results.first).to be_kind_of(ProjectMember)
      end
    end

    context 'when parent is a group' do
      let(:group) { create(:group) }
      let(:board) { create(:board, group: group) }
      let(:user) { create(:user) }

      before do
        group.add_developer(user)
      end

      it 'requests correct relations' do
        expect_next_instance_of(GroupMembersFinder) do |instance|
          expect(instance).to receive(:execute).with(include_relations: [:direct, :descendants, :inherited]).and_call_original
        end

        subject.execute
      end

      it 'finds GroupMembers with GroupMemberFinder' do
        results = subject.execute

        expect(subject.instance_variable_get(:@finder_service)).to be_kind_of(GroupMembersFinder)
        expect(results.first).to be_kind_of(GroupMember)
      end
    end
  end
end

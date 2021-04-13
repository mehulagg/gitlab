# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dast::Branch do
  let_it_be(:dast_profile) { create(:dast_profile) }

  subject { described_class.new(dast_profile) }

  describe '#project' do
    it 'delegates to profile.project' do
      expect(subject.project).to eq(dast_profile.project)
    end
  end

  context 'when profile.branch_name is nil' do
    context 'when the associated project does not have a repository' do
      describe '#name' do
        it 'returns nil' do
          expect(subject.name).to be_nil
        end
      end

      describe '#exists' do
        it 'returns false' do
          expect(subject.exists).to eq(false)
        end
      end
    end

    context 'when the associated project has a repository' do
      let_it_be(:dast_profile) { create(:dast_profile, project: create(:project, :repository)) }

      describe '#name' do
        it 'returns project.default_branch' do
          expect(subject.name).to eq(subject.project.default_branch)
        end
      end

      describe '#exists' do
        it 'returns true' do
          expect(subject.exists).to eq(true)
        end
      end
    end
  end

  context 'when profile.branch_name is not nil' do
    let_it_be(:dast_profile) { create(:dast_profile, branch_name: 'orphaned-branch') }

    describe '#name' do
      it 'returns profile.branch_name' do
        expect(subject.name).to eq(dast_profile.branch_name)
      end
    end

    context 'when the associated project does not have a repository' do
      describe '#exists' do
        it 'returns false' do
          expect(subject.exists).to eq(false)
        end
      end
    end

    context 'when the associated branch has a repository and the branch exists' do
      let_it_be(:dast_profile) { create(:dast_profile, project: create(:project, :repository), branch_name: 'orphaned-branch') }

      describe '#exists' do
        it 'returns true' do
          expect(subject.exists).to eq(true)
        end
      end
    end
  end
end

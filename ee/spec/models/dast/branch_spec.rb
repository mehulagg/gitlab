# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dast::Branch do
  let_it_be(:dast_profile) { create(:dast_profile) }
  let_it_be(:dast_profile_with_repository) { create(:dast_profile, project: create(:project, :repository)) }

  subject { described_class.new(dast_profile) }

  describe 'instance methods' do
    context 'when the associated project does not have a repository' do
      describe '#exists' do
        it 'returns false' do
          expect(subject.exists).to eq(false)
        end
      end
    end

    context 'when profile.branch_name is nil' do
      let_it_be(:dast_profile) { create(:dast_profile, branch_name: nil) }

      describe '#name' do
        it 'returns nil' do
          expect(subject.name).to be_nil
        end
      end

      context 'when the associated project has a repository' do
        subject { described_class.new(dast_profile_with_repository) }

        describe '#exists' do
          it 'returns true' do
            expect(subject.exists).to eq(true)
          end
        end
      end
    end

    context 'when profile.branch_name is not nil' do
      describe '#name' do
        it 'returns profile.branch_name' do
          expect(subject.name).to eq(dast_profile.branch_name)
        end
      end

      context 'when the branch exists in the associated repository' do
        subject { described_class.new(dast_profile_with_repository) }

        describe '#exists' do
          it 'returns true' do
            expect(subject.exists).to eq(true)
          end
        end
      end
    end
  end
end

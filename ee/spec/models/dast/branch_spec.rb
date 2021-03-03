# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dast::Branch do
  let_it_be(:project) { create(:project) }

  subject { described_class.new(project) }

  describe 'instance methods' do
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
      let_it_be(:project) { create(:project, :repository) }

      describe '#name' do
        it 'returns the default_branch' do
          expect(subject.name).to eq(project.default_branch)
        end
      end

      describe '#exists' do
        it 'returns true' do
          expect(subject.exists).to eq(true)
        end
      end
    end
  end
end

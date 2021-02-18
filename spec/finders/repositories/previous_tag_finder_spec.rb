# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Repositories::PreviousTagFinder do
  let(:project) { build_stubbed(:project) }
  let(:finder) { described_class.new(project) }

  describe '#execute' do
    context 'when there is a previous tag' do
      it 'returns the previous tag' do
        tag1 = double(:tag1, name: 'v1.0.0')
        tag2 = double(:tag2, name: 'v1.1.0')
        tag3 = double(:tag3, name: 'v2.0.0')
        tag4 = double(:tag4, name: '1.0.0')

        allow(project.repository)
          .to receive(:tags)
          .and_return([tag1, tag3, tag2, tag4])

        expect(finder.execute('2.1.0')).to eq(tag3)
        expect(finder.execute('2.0.0')).to eq(tag2)
        expect(finder.execute('1.5.0')).to eq(tag2)
        expect(finder.execute('1.0.1')).to eq(tag1)
      end
    end

    context 'when there is no previous tag' do
      it 'returns nil' do
        tag1 = double(:tag1, name: 'v1.0.0')
        tag2 = double(:tag2, name: 'v1.1.0')

        allow(project.repository)
          .to receive(:tags)
          .and_return([tag1, tag2])

        expect(finder.execute('1.0.0')).to be_nil
      end
    end
  end
end

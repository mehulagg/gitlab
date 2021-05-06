# frozen_string_literal: true

require 'fast_spec_helper'

RSpec.describe Gitlab::Ci::Config::Normalizer::NumberStrategy do
  describe '.applies_to?' do
    subject { described_class.applies_to?(config) }

    context 'with numbers' do
      let(:config) { 5 }

      it { is_expected.to be_truthy }
    end

    context 'with hash that has :number key' do
      let(:config) { { number: 5 } }

      it { is_expected.to be_truthy }
    end

    context 'with a float number' do
      let(:config) { 5.5 }

      it { is_expected.to be_falsey }
    end

    context 'with hash that does not have :number key' do
      let(:config) { { matrix: 5 } }

      it { is_expected.to be_falsey }
    end
  end

  describe '.build_from' do
    subject { described_class.build_from('test', config) }

    shared_examples 'parallelized job' do
      it { expect(subject.size).to eq(3) }

      it 'has attributes' do
        expect(subject.map(&:attributes)).to match_array(
          [
            { name: 'test 1/3', instance: 1, parallel: { total: 3 } },
            { name: 'test 2/3', instance: 2, parallel: { total: 3 } },
            { name: 'test 3/3', instance: 3, parallel: { total: 3 } }
          ]
        )
      end

      it 'has parallelized name' do
      end

      describe 'names' do
        it 'are parallelized' do
          expect(subject.map(&:name)).to match_array(['test 1/3', 'test 2/3', 'test 3/3'])
        end

        it 'match the class-level extraction regex' do
          subject.map(&:name).each do |job_name|
            expect(job_name).to_match described_class::SUFFIX_REGEX
          end
        end
      end
    end

    context 'with numbers' do
      let(:config) { 3 }

      it_behaves_like 'parallelized job'
    end

    context 'with hash that has :number key' do
      let(:config) { { number: 3 } }

      it_behaves_like 'parallelized job'
    end
  end
end

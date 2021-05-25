# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RunnerGroup do
  describe '.create' do
    let(:attributes) { { name: 'important' } }

    subject { described_class.create(attributes) }

    context 'with valid attributes' do
      it { is_expected.to be_persisted }

      it 'returns the new group' do
        expect(subject.name).to eq('important')
      end
    end

    context 'with a duplicate name' do
      before do
        described_class.create(attributes)
      end

      it { is_expected.not_to be_persisted }
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['PayloadAlertFieldPathSegment'] do
  specify { expect(described_class.graphql_name).to eq('PayloadAlertFieldPathSegment') }

  describe '.coerce_input' do
    subject { described_class.coerce_isolated_input(input) }

    context 'with string' do
      let(:input) { 'string' }

      it { is_expected.to eq input }
    end

    context 'with integer' do
      let(:input) { 16 }

      it { is_expected.to eq input }
    end

    context 'with non-string or integer' do
      let(:input) { [1, 2, 3] }

      it { is_expected.to eq nil }
    end
  end

  describe '.coerce_result' do
    subject { described_class.coerce_isolated_result(input) }

    context 'with string' do
      let(:input) { 'string' }

      it { is_expected.to eq input }
    end

    context 'with integer' do
      let(:input) { 16 }

      it { is_expected.to eq input }
    end

    context 'with non-string or integer' do
      let(:input) { [1, 2, 3] }

      it { is_expected.to eq input.to_s }
    end
  end
end

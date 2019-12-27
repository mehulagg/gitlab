# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Parsers do
  describe '.fabricate!' do
    subject { described_class.fabricate!(file_type) }

    context 'when file_type exists' do
      let(:file_type) { 'junit' }

      it 'fabricates the class' do
        is_expected.to be_a(described_class::Test::Junit)
      end
    end

    context 'when file_type does not exist' do
      let(:file_type) { 'undefined' }

      it 'raises an error' do
        expect { subject }.to raise_error(Gitlab::Ci::Parsers::ParserNotFoundError)
      end
    end
  end
end

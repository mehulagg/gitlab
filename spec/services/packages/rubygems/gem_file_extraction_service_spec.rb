# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Packages::Rubygems::GemFileExtractionService do
  let(:package_file) { create(:package_file, :gem) }
  let(:file) { package_file.file }
  let(:service) { described_class.new(file) }

  describe '#execute' do
    subject { service.execute }

    context 'no gem file' do
      let(:file) { nil }

      it 'returns an error' do
        result = subject

        expect(result.status).to eq(:error)
        expect(result.message).to eq('No gem file provided')
      end
    end

    context 'valid gem file' do
      it 'returns a hash of files' do
        expect(result).to eq({})
      end
    end
  end
end

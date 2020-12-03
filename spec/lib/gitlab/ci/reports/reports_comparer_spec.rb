# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Reports::ReportsComparer do
  let(:comparer) { described_class.new(base_report, head_report) }
  let(:base_report) { 'base' }
  let(:head_report) { 'head' }

  describe '#initialize' do
    context 'sets getter for reports' do
      it 'return base report' do
        expect(comparer.base_report).to eq('base')
      end

      it 'return head report' do
        expect(comparer.head_report).to eq('head')
      end
    end
  end

  describe '#status' do
    subject { comparer.status }

    it 'returns not implemented error' do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end

  describe '#existing_errors' do
    subject { comparer.existing_errors }

    it 'returns not implemented error' do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end

  describe '#resolved_errors' do
    subject { comparer.resolved_errors }

    it 'returns not implemented error' do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end

  describe '#errors_count' do
    subject { comparer.errors_count }

    it 'returns not implemented error' do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end

  describe '#resolved_count' do
    subject { comparer.resolved_count }

    it 'returns not implemented error' do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end

  describe '#total_count' do
    subject { comparer.total_count }

    it 'returns not implemented error' do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end
end

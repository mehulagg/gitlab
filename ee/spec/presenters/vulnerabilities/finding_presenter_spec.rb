# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::FindingPresenter do
  let(:presenter) { described_class.new(occurrence) }
  let(:occurrence) { build_stubbed(:vulnerabilities_occurrence) }

  describe '#blob_path' do
    subject { presenter.blob_path }

    context 'without a sha' do
      it { is_expected.to be_blank }
    end

    context 'with a sha' do
      before do
        occurrence.sha = 'abc'
      end

      it { is_expected.to include(occurrence.sha) }

      context 'without start_line or end_line' do
        before do
          allow(presenter).to receive(:location)
            .and_return({ 'file' => 'a.txt' })
        end

        it { is_expected.to end_with('a.txt') }
      end

      context 'with start_line only' do
        before do
          allow(presenter).to receive(:location)
            .and_return({ 'file' => 'a.txt', 'start_line' => 1 })
        end

        it { is_expected.to end_with('#L1') }
      end

      context 'with start_line and end_line' do
        before do
          allow(presenter).to receive(:location)
            .and_return({ 'file' => 'a.txt', 'start_line' => 1, 'end_line' => 2 })
        end

        it { is_expected.to end_with('#L1-2') }
      end

      context 'without file' do
        before do
          allow(presenter).to receive(:location)
            .and_return({ 'foo' => 123 })
        end

        it { is_expected.to be_blank }
      end

      context 'without location' do
        before do
          allow(presenter).to receive(:location)
            .and_return({})
        end

        it { is_expected.to be_blank }
      end
    end
  end
end

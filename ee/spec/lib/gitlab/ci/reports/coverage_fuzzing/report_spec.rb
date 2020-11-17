# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Reports::CoverageFuzzing::Report do
  let(:report) { described_class.new }

  describe '#add_crash' do
    let(:crash) do
      {
          crash_address: "0x602000001573",
          crash_type: "Heap-buffer-overflow\nREAD 1",
          crash_state: "FuzzMe\nstart\nstart+0x0\n\n",
          stacktrace_snippet: fixture_file('stacktrace_snippet.txt', dir: 'ee')
      }
    end

    subject { report.add_crash(crash) }

    it 'stores given crash params in the map' do
      subject

      expect(report.crashes.length).to eq(1)
      expect(report.crashes[0].crash_address).to eq("0x602000001573")
      expect(report.crashes[0].crash_type).to eq("Heap-buffer-overflow\nREAD 1")
      expect(report.crashes[0].crash_state).to eq("FuzzMe\nstart\nstart+0x0\n\n")
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CodequalityReportsComparerEntity do
  let(:entity) { described_class.new(comparer) }
  let(:comparer) { Gitlab::Ci::Reports::CodequalityReportsComparer.new(base_report, head_report) }
  let(:base_report) { Gitlab::Ci::Reports::CodequalityReports.new }
  let(:head_report) { Gitlab::Ci::Reports::CodequalityReports.new }
  let(:minor_degradation) { build(:codequality_degradation_1) }
  let(:major_degradation) { build(:codequality_degradation_3) }

  describe '#as_json' do
    subject { entity.as_json }

    context 'when base and head report have errors' do
      before do
        base_report.add_degradation(minor_degradation)
        head_report.add_degradation(major_degradation)
      end

      it 'contains correct compared codequality report details', :aggregate_failures do
        expect(subject[:status]).to eq(Gitlab::Ci::Reports::CodequalityReportsComparer::STATUS_FAILED)
        expect(subject[:resolved_errors].first).to include(:description, :severity, :file_path, :line)
        expect(subject[:new_errors].first).to include(:description, :severity, :file_path, :line)
        expect(subject[:existing_errors]).to be_empty
        expect(subject[:summary]).to include(total: 1, resolved: 1, errored: 1)
      end
    end

    context 'when head report have several errors' do
      before do
        head_report.add_degradation(minor_degradation)
        head_report.add_degradation(major_degradation)
      end

      it 'returns codequality report sorted by severity' do
        expect(subject[:new_errors].first[:severity]).to eq("major")
        expect(subject[:new_errors].second[:severity]).to eq("minor")
      end
    end
  end
end

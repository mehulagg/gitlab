# frozen_string_literal: true

require 'spec_helper'

describe Ci::BuildReportResults do
  let(:build_report_results) { build(:ci_build_report_results, :with_junit_success) }

  describe 'associations' do
    it { is_expected.to belong_to(:build) }
    it { is_expected.to belong_to(:project) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:project) }
    it { is_expected.to validate_presence_of(:build) }

    context 'when attributes are valid' do
      it 'returns no errors' do
        expect(build_report_results).to be_valid
      end
    end

    context 'when data is invalid' do
      it 'returns errors' do
        build_report_results.data = { invalid: 'data' }.to_json

        expect(build_report_results).to be_invalid
        expect(build_report_results.errors.full_messages).to eq(["Data must be a valid json schema"])
      end
    end
  end
end

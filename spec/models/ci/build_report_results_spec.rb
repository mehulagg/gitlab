# frozen_string_literal: true

require 'spec_helper'

describe Ci::BuildReportResults do
  let(:build_report_results) { create(:build_report_results, :junit_success) }

  describe "associations" do
    it { is_expected.to belong_to(:build) }
  end

  describe 'validations' do
    it_behaves_like 'having unique enum values'

    it { is_expected.to validate_presence_of(:param_type) }
    it { is_expected.to validate_presence_of(:build) }
  end
end

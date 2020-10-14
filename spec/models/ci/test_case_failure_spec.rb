# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::TestCaseFailure do
  describe 'relationships' do
    it { is_expected.to belong_to(:build) }
    it { is_expected.to belong_to(:test_case) }
  end

  describe 'validations' do
    subject { build(:ci_test_case_failure) }

    it { is_expected.to validate_presence_of(:test_case_id) }
    it { is_expected.to validate_presence_of(:build_id) }
    it { is_expected.to validate_presence_of(:ref_path) }
    it { is_expected.to validate_presence_of(:failed_at) }
  end

  describe '.recent_failures_count' do
    it 'returns the number of failures for each test case key hash for the past 14 days by default' do
      project = create(:project)
      tc_1 = create(:ci_test_case, project: project)
      tc_2 = create(:ci_test_case, project: project)
      tc_3 = create(:ci_test_case, project: project)
      ref_path = 'refs/heads/master'
      other_ref_path = 'refs/heads/develop'

      # These are the only ones that should be counted
      create_list(:ci_test_case_failure, 2, test_case: tc_1, ref_path: ref_path, failed_at: 1.day.ago)
      create_list(:ci_test_case_failure, 1, test_case: tc_2, ref_path: ref_path, failed_at: 3.days.ago)

      # These ones are excluded from the count
      create(:ci_test_case_failure, test_case: tc_3, ref_path: ref_path, failed_at: 1.day.ago)
      create(:ci_test_case_failure, test_case: tc_2, ref_path: ref_path, failed_at: 15.days.ago)
      create(:ci_test_case_failure, test_case: tc_2, ref_path: other_ref_path, failed_at: 3.days.ago)

      result = described_class.recent_failures_count(
        project: project,
        ref_path: ref_path,
        test_case_keys: [tc_1.key_hash, tc_2.key_hash]
      )

      expect(result).to eq(
        tc_1.key_hash => 2,
        tc_2.key_hash => 1
      )
    end
  end
end

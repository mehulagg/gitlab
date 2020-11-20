# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Reports::Security::Remediation do
  let(:remediation) { build(:ci_reports_security_remediation) }

  describe '#diff_file' do
    subject { remediation.diff_file.read }

    it { is_expected.to eq('foo') }
  end

  describe '#checksum' do
    subject { remediation.checksum }

    it { is_expected.to eq('2c26b46b68ffc68ff99b453c1d30413413422d706483bfa0f98a5e886266e7ae') }
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::Remediation do
  it { is_expected.to have_many(:finding_remediations).class_name('Vulnerabilities::FindingRemediation') }
  it { is_expected.to have_many(:findings).through(:finding_remediations) }

  it { is_expected.to validate_presence_of(:summary) }
  it { is_expected.to validate_presence_of(:file) }
  it { is_expected.to validate_length_of(:summary).is_at_most(200) }
end

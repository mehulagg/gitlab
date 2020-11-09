# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::Remediation do
  it { is_expected.to have_many(:finding_remediations) }
  it { is_expected.to have_many(:findings).through(:finding_remediations) }

  it { is_expected.to validate_presence_of(:summary) }
  it { is_expected.to validate_presence_of(:diff) }
  it { is_expected.to validate_length_of(:summary).is_at_most(200) }
  it { is_expected.to validate_length_of(:diff).is_at_most(1_000_000) }
end

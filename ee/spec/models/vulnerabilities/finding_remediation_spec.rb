# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::FindingRemediation do
  it { is_expected.to belong_to(:finding).required }
  it { is_expected.to belong_to(:remediation).required }
end

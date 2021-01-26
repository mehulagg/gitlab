# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::FindingRemediation do
  it { is_expected.to belong_to(:finding).class_name('Vulnerabilities::Finding').required }
  it { is_expected.to belong_to(:remediation).class_name('Vulnerabilities::Remediation').required }
end

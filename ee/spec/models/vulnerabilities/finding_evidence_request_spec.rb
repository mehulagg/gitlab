require 'spec_helper'

RSpec.describe Vulnerabilities::FindingEvidenceRequest do
  it { is_expected.to belong_to(:finding_evidence).class_name('Vulnerabilities::FindingEvidence').required }
end

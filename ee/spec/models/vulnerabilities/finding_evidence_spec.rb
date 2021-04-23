# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::FindingEvidence do
  it { is_expected.to belong_to(:finding).class_name('Vulnerabilities::Finding').required }
  it { is_expected.to have_many(:requests).class_name('Vulnerabilities::FindingEvidenceRequest').with_foreign_key('vulnerability_finding_evidence_id').inverse_of(:finding_evidence) }
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::FindingEvidenceResponse do
  it { is_expected.to belong_to(:finding_evidence).class_name('Vulnerabilities::FindingEvidence').inverse_of(:responses).required }
  it { is_expected.to have_many(:headers).class_name('Vulnerabilities::Findings::Evidences::Header').with_foreign_key('vulnerability_finding_evidence_response_id').inverse_of(:response) }
end

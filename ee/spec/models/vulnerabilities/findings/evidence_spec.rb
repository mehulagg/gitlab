# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::Findings::Evidence do
  it { is_expected.to belong_to(:finding).class_name('Vulnerabilities::Finding').required }
  it { is_expected.to have_one(:request).class_name('Vulnerabilities::Findings::Evidences::Request').with_foreign_key('vulnerability_finding_evidence_id').inverse_of(:evidence) }
  it { is_expected.to have_one(:response).class_name('Vulnerabilities::Findings::Evidences::Response').with_foreign_key('vulnerability_finding_evidence_id').inverse_of(:evidence) }
end

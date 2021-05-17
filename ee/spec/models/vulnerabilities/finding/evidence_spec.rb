# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::Finding::Evidence do
  it { is_expected.to belong_to(:finding).class_name('Vulnerabilities::Finding').required }
  it { is_expected.to have_one(:request).class_name('Vulnerabilities::Finding::Evidence::Request').with_foreign_key('vulnerability_finding_evidence_id').inverse_of(:evidence) }
  it { is_expected.to have_one(:response).class_name('Vulnerabilities::Finding::Evidence::Response').with_foreign_key('vulnerability_finding_evidence_id').inverse_of(:evidence) }
end

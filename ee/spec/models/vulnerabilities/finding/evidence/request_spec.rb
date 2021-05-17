# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::Finding::Evidence::Request do
  it { is_expected.to belong_to(:evidence).class_name('Vulnerabilities::Finding::Evidence').inverse_of(:request).required }
  it { is_expected.to have_many(:headers).class_name('Vulnerabilities::Finding::Evidence::Header').with_foreign_key('vulnerability_finding_evidence_request_id').inverse_of(:request) }
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::FindingEvidenceRequest do
  it { is_expected.to belong_to(:finding_evidence).class_name('Vulnerabilities::FindingEvidence').inverse_of(:requests).required }
end

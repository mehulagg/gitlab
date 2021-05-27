# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::Finding::Evidence::Header do
  it { is_expected.to belong_to(:request).class_name('Vulnerabilities::Finding::Evidence::Request').inverse_of(:headers).optional }
  it { is_expected.to belong_to(:response).class_name('Vulnerabilities::Finding::Evidence::Response').inverse_of(:headers).optional }

  it { is_expected.to validate_length_of(:name).is_at_most(255) }
  it { is_expected.to validate_length_of(:value).is_at_most(8192) }

  describe '.request_or_response_is_set' do
    let(:header) { build(:vulnerabilties_finding_evidence_header) }

    it 'is invalid if there is no request or response' do
      expect(header).not_to be_valid
    end

    it 'validates if there is a response' do
      header.response = build(:vulnerabilties_finding_evidence_response)
      expect(header).to be_valid
    end

    it 'validates if there is a request' do
      header.request = build(:vulnerabilties_finding_evidence_request)
      expect(header).to be_valid
    end

    it 'is invalid if there is a request and a response' do
      header.request = build(:vulnerabilties_finding_evidence_request)
      header.response = build(:vulnerabilties_finding_evidence_response)
      expect(header).not_to be_valid
    end
  end
end

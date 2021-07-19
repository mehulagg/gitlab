# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::Finding::Evidence::Request do
  it { is_expected.to belong_to(:evidence).class_name('Vulnerabilities::Finding::Evidence').inverse_of(:request).required }
  it { is_expected.to have_many(:headers).class_name('Vulnerabilities::Finding::Evidence::Header').with_foreign_key('vulnerability_finding_evidence_request_id').inverse_of(:request) }

  it { is_expected.to validate_length_of(:method).is_at_most(32) }
  it { is_expected.to validate_length_of(:url).is_at_most(2048) }

  it_behaves_like 'body shared examples', :vulnerabilties_finding_evidence_request

  describe '.any_field_present' do
    let_it_be(:evidence) { build(:vulnerabilties_finding_evidence) }
    let_it_be(:request) { Vulnerabilities::Finding::Evidence::Request.new(evidence: evidence) }

    it 'is invalid if there are no fields present' do
      expect(request).not_to be_valid
    end

    it 'validates if there is only a method' do
      request.method = 'request-method'
      expect(request).to be_valid
    end

    it 'validates if there is only a url' do
      request.url = 'request-url.example'
      expect(request).to be_valid
    end
  end
end

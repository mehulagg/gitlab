# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::Finding::Evidence::Source do
  it { is_expected.to belong_to(:evidence).class_name('Vulnerabilities::Finding::Evidence').inverse_of(:source).required }

  it { is_expected.to validate_length_of(:name).is_at_most(2048) }
  it { is_expected.to validate_length_of(:url).is_at_most(2048) }

  describe '.any_field_present' do
    let_it_be(:evidence) { build(:vulnerabilties_finding_evidence) }
    let_it_be(:source) { Vulnerabilities::Finding::Evidence::Source.new(evidence: evidence) }

    it 'is invalid if there are no fields present' do
      expect(source).not_to be_valid
    end

    it 'validates if there is only a name' do
      source.name = 'source-name'
      expect(source).to be_valid
    end

    it 'validates if there is only a url' do
      source.url = 'source-url.example'
      expect(source).to be_valid
    end
  end
end

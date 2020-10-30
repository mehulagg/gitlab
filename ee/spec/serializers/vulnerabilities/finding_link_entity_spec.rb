# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::FindingLinkEntity do
  let(:finding_link) { create(:finding_link) }

  let(:entity) do
    described_class.represent(finding_link)
  end

  describe '#as_json' do
    subject { entity.as_json }

    it 'contains required fields' do
      expect(subject).to include(:name, :url)
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::ResponseEntity do
  let(:response) { create(:vulnerabilities_occurrence).evidence[:response] }

  let(:entity) do
    described_class.represent(response)
  end

  describe '#as_json' do
    subject { entity.as_json }

    it 'contains required fields' do
      expect(subject).to include(:headers, :reason_phrase, :status_code)
    end
  end
end

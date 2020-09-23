# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::RequestEntity do
  let(:request) { create(:vulnerabilities_occurrence).evidence[:request] }

  let(:entity) do
    described_class.represent(request)
  end

  describe '#as_json' do
    subject { entity.as_json }

    it 'contains required fields' do
      expect(subject).to include(:headers, :method, :url)
    end
  end
end

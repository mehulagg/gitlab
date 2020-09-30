# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Vulnerabilities::CalculateFindingUUID do
  let_it_be(:value) { "GitLab" }
  # Calculated using uuidtools gem
  let_it_be(:development_proper_uuid) { "5b593e54-90f5-504b-8805-5394a4d14b94" }
  let_it_be(:production_proper_uuid) { "4961388b-9d8e-5da0-a499-3ef5da58daf0" }

  subject { described_class.new.call(value: value) }

  context 'in development' do
    before do
      allow(Rails).to receive(:env).and_return(:development)
    end

    it { is_expected.to eq(development_proper_uuid) }
  end

  context 'in production' do
    before do
      allow(Rails).to receive(:env).and_return(:production)
    end

    it { is_expected.to eq(production_proper_uuid) }
  end
end

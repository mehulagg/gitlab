# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JsonSchemaValidator do
  describe '#validates_each' do
    let(:test_value) { 'bar' }
    let(:mock_subject) { double(:subject) }
    let(:validator) { described_class.new(attributes: [:foo], filename: schema_name, base_directory: %w(spec fixtures)) }

    subject(:validate_subject) { validator.validate_each(mock_subject, :foo, test_value) }

    before do
      allow(JSON::Validator).to receive(:validate).and_return(true)
    end

    context 'when the schema file exists on CE' do
      let(:schema_name) { 'ce_sample_schema' }
      let(:schema_path) { Rails.root.join('spec', 'fixtures', 'ce_sample_schema.json').to_s }

      it 'calls the validator with CE schema' do
        validate_subject

        expect(JSON::Validator).to have_received(:validate).with(schema_path, test_value)
      end
    end

    context 'when the schema file exists on EE' do
      let(:schema_name) { 'ee_sample_schema' }
      let(:schema_path) { Rails.root.join('ee', 'spec', 'fixtures', 'ee_sample_schema.json').to_s }

      it 'calls the validator with EE schema' do
        validate_subject

        expect(JSON::Validator).to have_received(:validate).with(schema_path, test_value)
      end
    end
  end
end

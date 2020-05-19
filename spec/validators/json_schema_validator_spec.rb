# frozen_string_literal: true

require 'spec_helper'

describe JsonSchemaValidator do
  describe '#validates_each' do
    let(:build_report_results) { build(:ci_build_report_results, :with_junit_success) }

    subject { validator.validate(build_report_results) }

    context 'when file_path is set' do
      let(:validator) { described_class.new(attributes: [:data], file_name: "build_report_results_data") }

      context 'when data is valid' do
        it 'returns no errors' do
          subject

          expect(build_report_results.errors).to be_empty
        end
      end

      context 'when data is invalid' do
        it 'returns json schema is invalid' do
          build_report_results.data =  { invalid: 'data' }.to_json

          validator.validate(build_report_results)

          expect(build_report_results.errors.size).to eq(1)
          expect(build_report_results.errors.full_messages).to eq(["Data must be a valid json schema"])
        end
      end
    end

    context 'when file_path is not set' do
      let(:validator) { described_class.new(attributes: [:data]) }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end
end

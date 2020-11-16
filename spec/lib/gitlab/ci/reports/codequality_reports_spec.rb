# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Reports::CodequalityReports do
  let(:codequality_report) { described_class.new }
  let(:degredation_1) do
    {
      "categories": [
        "Complexity"
      ],
      "check_name": "argument_count",
      "content": {
        "body": ""
      },
      "description": "Method `new_array` has 12 arguments (exceeds 4 allowed). Consider refactoring.",
      "fingerprint": "15cdb5c53afd42bc22f8ca366a08d547",
      "location": {
        "path": "foo.rb",
        "lines": {
          "begin": 10,
          "end": 10
        }
      },
      "other_locations": [],
      "remediation_points": 900000,
      "severity": "major",
      "type": "issue",
      "engine_name": "structure"
    }
  end

  let(:degredation_2) do
    {
      "type": "Issue",
      "check_name": "Rubocop/Metrics/ParameterLists",
      "description": "Avoid parameter lists longer than 5 parameters. [12/5]",
      "categories": [
        "Complexity"
      ],
      "remediation_points": 550000,
      "location": {
        "path": "foo.rb",
        "positions": {
          "begin": {
            "column": 14,
            "line": 10
          },
          "end": {
            "column": 39,
            "line": 10
          }
        }
      },
      "content": {
        "body": "This cop checks for methods with too many parameters.\nThe maximum number of parameters is configurable.\nKeyword arguments can optionally be excluded from the total count."
      },
      "engine_name": "rubocop",
      "fingerprint": "ab5f8b935886b942d621399f5a2ca16e",
      "severity": "minor"
    }
  end

  it { expect(codequality_report.degredations).to eq({}) }

  describe '#add_degredation' do
    context 'when there is a degredation' do
      before do
        codequality_report.add_degredation(degredation_1[:fingerprint], degredation_1)
      end

      it 'adds degredation to codequality report' do
        expect(codequality_report.degredations.keys).to eq([degredation_1[:fingerprint]])
        expect(codequality_report.degredations.values.size).to eq(1)
      end
    end
  end

  describe '#set_error_message' do
    context 'when there is an error' do
      it 'sets errors' do
        codequality_report.set_error_message("error")

        expect(codequality_report.error_message).to eq("error")
      end
    end
  end

  describe '#degredations_count' do
    subject { codequality_report.degredations_count }

    context 'when there are many degredations' do
      before do
        codequality_report.add_degredation(degredation_1[:fingerprint], degredation_1)
        codequality_report.add_degredation(degredation_2[:fingerprint], degredation_2)
      end

      it 'returns the number of degredations' do
        expect(subject).to eq(2)
      end
    end
  end

  describe '#all_degredations' do
    subject { codequality_report.all_degredations }

    context 'when there are many degredations' do
      before do
        codequality_report.add_degredation(degredation_1[:fingerprint], degredation_1)
        codequality_report.add_degredation(degredation_2[:fingerprint], degredation_2)
      end

      it 'returns all degredations' do
        subject

        expect(subject).to contain_exactly(degredation_1, degredation_2)
      end
    end
  end
end

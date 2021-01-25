# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::PipelineArtifacts::CodeQualityPresenter do
  let(:pipeline_artifact) { create(:ci_pipeline_artifact, :codequality_report) }

  subject(:presenter) { described_class.new(pipeline_artifact) }

  describe '#for_files' do
    subject(:mr_diff_report) { presenter.for_files(filenames) }

    context 'when filenames is empty' do
      let(:filenames) { %w() }

      it 'returns hash without quality data' do
        expect(mr_diff_report).to match(files: {})
      end
    end

    context 'when filenames do not match code filename' do
      let(:filenames) { %w(demo.rb) }

      it 'returns hash without quality data' do
        expect(mr_diff_report).to match(files: {})
      end
    end

    context 'when filenames matches' do
      context 'when asking for one filename' do
        let(:filenames) { %w(file_a.rb) }

        it 'returns quality data for the given filename' do
          expect(mr_diff_report).to match(
            files: {
              "file_a.rb" => [
                { line: 10, description: "Method `new_array` has 12 arguments (exceeds 4 allowed). Consider refactoring.", severity: "major" },
                { line: 10, description: "Avoid parameter lists longer than 5 parameters. [12/5]", severity: "minor" }
              ]
            }
          )
        end
      end

      context 'when asking for multiple filenames' do
        let(:filenames) { %w(file_a.rb file_b.rb) }

        it 'returns quality data for the given filenames' do
          expect(mr_diff_report).to match(
            files: {
              "file_a.rb" => [
                { line: 10, description: "Method `new_array` has 12 arguments (exceeds 4 allowed). Consider refactoring.", severity: "major" },
                { line: 10, description: "Avoid parameter lists longer than 5 parameters. [12/5]", severity: "minor" }
              ],
              "file_b.rb" => [
                { line: 20, description: "Avoid parameter lists longer than 5 parameters. [8/5]", severity: "minor" }
              ]
            }
          )
        end
      end
    end
  end
end

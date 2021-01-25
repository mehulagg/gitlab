# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::PipelineArtifacts::CodeQualityPresenter do
  let(:pipeline_artifact) { create(:ci_pipeline_artifact, :codequality_report) }

  subject(:presenter) { described_class.new(pipeline_artifact) }

  describe '#for_files' do
    subject(:quality_data) { presenter.for_files(filenames) }

    context 'when code quality has data' do
      context 'when filenames is empty' do
        let(:filenames) { %w() }

        it 'returns hash without quality' do
          expect(quality_data).to match(files: {})
        end
      end

      context 'when filenames do not match code quality data' do
        let(:filenames) { %w(demo.rb) }

        it 'returns hash without quality' do
          expect(quality_data).to match(files: {})
        end
      end

      context 'when filenames matches code quality data' do
        context 'when asking for one filename' do
          let(:filenames) { %w(file_a.rb) }

          it 'returns quality for the given filename' do
            expect(quality_data).to match(
              files: {
                "file_a.rb" => [
                  { line: 5, description: "Method `new_array` has 8 arguments (exceeds 4 allowed). Consider refactoring.", severity: "major" },
                  { line: 5, description: "Avoid parameter lists longer than 5 parameters. [8/5]", severity: "minor" }
                ]
              }
            )
          end
        end

        context 'when asking for multiple filenames' do
          let(:filenames) { %w(file_a.rb file_b.rb) }

          it 'returns quality for the given filenames' do
            expect(quality_data).to match(
              files: {
                "file_a.rb" => [
                  { line: 5, description: "Method `new_array` has 8 arguments (exceeds 4 allowed). Consider refactoring.", severity: "major" },
                  { line: 5, description: "Avoid parameter lists longer than 5 parameters. [8/5]", severity: "minor" }
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
end

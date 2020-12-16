# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SortVariables do
  let(:variable_inside_variable_enabled) { false }

  before do
    stub_feature_flags(variable_inside_variable: variable_inside_variable_enabled)
  end

  describe '#check_errors' do
    context 'when FF :variable_inside_variable is disabled' do
      let(:variable_inside_variable_enabled) { false }

      context 'table tests' do
        using RSpec::Parameterized::TableSyntax

        where do
          {
            "empty array": {
              variables: []
            },
            "simple expansions": {
              variables: [
                { key: 'variable', value: 'value' },
                { key: 'variable2', value: 'result' },
                { key: 'variable3', value: 'key$variable$variable2' }
              ]
            },
            "complex expansion": {
              variables: [
                { key: 'variable', value: 'value' },
                { key: 'variable2', value: 'key${variable}' }
              ]
            },
            "complex expansions with missing variable for Windows": {
              variables: [
                { key: 'variable', value: 'value' },
                { key: 'variable3', value: 'key%variable%%variable2%' }
              ]
            },
            "out-of-order variable reference": {
              variables: [
                { key: 'variable2', value: 'key${variable}' },
                { key: 'variable', value: 'value' }
              ]
            },
            "array with cyclic dependency": {
              variables: [
                { key: 'variable', value: '$variable2' },
                { key: 'variable2', value: '$variable3' },
                { key: 'variable3', value: 'key$variable$variable2' }
              ]
            }
          }
        end

        with_them do
          subject { SortVariables.new(variables) }

          it 'does not report error' do
            expect(subject.check_errors).to eq(nil)
          end

          it 'valid? reports true' do
            expect(subject.valid?).to eq(true)
          end
        end
      end
    end

    context 'when FF :variable_inside_variable is enabled' do
      let(:variable_inside_variable_enabled) { true }

      context 'table tests' do
        using RSpec::Parameterized::TableSyntax

        where do
          {
            "empty array": {
              variables: [],
              validation_result: nil
            },
            "simple expansions": {
              variables: [
                { key: 'variable', value: 'value' },
                { key: 'variable2', value: 'result' },
                { key: 'variable3', value: 'key$variable$variable2' }
              ],
              validation_result: nil
            },
            "cyclic dependency": {
              variables: [
                { key: 'variable', value: '$variable2' },
                { key: 'variable2', value: '$variable3' },
                { key: 'variable3', value: 'key$variable$variable2' }
              ],
              validation_result: 'circular variable reference detected: ["variable", "variable2", "variable3"]'
            }
          }
        end

        with_them do
          subject { SortVariables.new(variables) }

          it 'check_errors matches expected validation result' do
            expect(subject.check_errors).to eq(validation_result)
          end

          it 'valid? matches expected validation result' do
            expect(subject.valid?).to eq(validation_result.nil?)
          end
        end
      end
    end
  end

  describe '#sort' do
    context 'when FF :variable_inside_variable is disabled' do
      let(:variable_inside_variable_enabled) { false }

      context 'table tests' do
        using RSpec::Parameterized::TableSyntax

        where do
          {
            "empty array": {
              variables: []
            },
            "simple expansions": {
              variables: [
                { key: 'variable', value: 'value' },
                { key: 'variable2', value: 'result' },
                { key: 'variable3', value: 'key$variable$variable2' }
              ]
            },
            "complex expansion": {
              variables: [
                { key: 'variable', value: 'value' },
                { key: 'variable2', value: 'key${variable}' }
              ]
            },
            "complex expansions with missing variable for Windows": {
              variables: [
                { key: 'variable', value: 'value' },
                { key: 'variable3', value: 'key%variable%%variable2%' }
              ]
            },
            "out-of-order variable reference": {
              variables: [
                { key: 'variable2', value: 'key${variable}' },
                { key: 'variable', value: 'value' }
              ]
            },
            "array with cyclic dependency": {
              variables: [
                { key: 'variable', value: '$variable2' },
                { key: 'variable2', value: '$variable3' },
                { key: 'variable3', value: 'key$variable$variable2' }
              ]
            }
          }
        end

        with_them do
          subject { SortVariables.new(variables) }

          it 'does not expand variables' do
            expect(subject.sort).to eq(variables)
          end
        end
      end
    end

    context 'when FF :variable_inside_variable is enabled' do
      let(:variable_inside_variable_enabled) { true }

      context 'table tests' do
        using RSpec::Parameterized::TableSyntax

        where do
          {
            "empty array": {
              variables: [],
              result: []
            },
            "simple expansions, no reordering needed": {
              variables: [
                { key: 'variable', value: 'value' },
                { key: 'variable2', value: 'result' },
                { key: 'variable3', value: 'key$variable$variable2' }
              ],
              result: %w[variable variable2 variable3]
            },
            "complex expansion, reordering needed": {
              variables: [
                { key: 'variable2', value: 'key${variable}' },
                { key: 'variable', value: 'value' }
              ],
              result: %w[variable variable2]
            },
            "unused variables": {
              variables: [
                { key: 'variable', value: 'value' },
                { key: 'variable4', value: 'key$variable$variable3' },
                { key: 'variable2', value: 'result2' },
                { key: 'variable3', value: 'result3' }
              ],
              result: %w[variable variable3 variable4 variable2]
            },
            "missing variable": {
              variables: [
                { key: 'variable2', value: 'key$variable' }
              ],
              result: %w[variable2]
            },
            "complex expansions with missing variable": {
              variables: [
                { key: 'variable4', value: 'key${variable}${variable2}${variable3}' },
                { key: 'variable', value: 'value' },
                { key: 'variable3', value: 'value3' }
              ],
              result: %w[variable variable3 variable4]
            },
            "cyclic dependency causes original array to be returned": {
              variables: [
                { key: 'variable2', value: '$variable3' },
                { key: 'variable3', value: 'key$variable$variable2' },
                { key: 'variable', value: '$variable2' }
              ],
              result: %w[variable2 variable3 variable]
            }
          }
        end

        with_them do
          subject { SortVariables.new(variables) }

          it 'sort returns correctly sorted variables' do
            expect(subject.sort.map { |var| var[:key] }).to eq(result)
          end
        end
      end
    end
  end
end

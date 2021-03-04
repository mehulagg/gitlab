# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ExpandVariables do
  shared_examples 'common variable expansion' do |expander|
    using RSpec::Parameterized::TableSyntax

    where do
      {
        "no expansion": {
          value: 'key',
          result: 'key',
          variables: []
        },
        "simple expansion": {
          value: 'key$variable',
          result: 'keyvalue',
          variables: [
            { key: 'variable', value: 'value' }
          ]
        },
        "simple with hash of variables": {
          value: 'key$variable',
          result: 'keyvalue',
          variables: {
            'variable' => 'value'
          }
        },
        "complex expansion": {
          value: 'key${variable}',
          result: 'keyvalue',
          variables: [
            { key: 'variable', value: 'value' }
          ]
        },
        "simple expansions": {
          value: 'key$variable$variable2',
          result: 'keyvalueresult',
          variables: [
            { key: 'variable', value: 'value' },
            { key: 'variable2', value: 'result' }
          ]
        },
        "complex expansions": {
          value: 'key${variable}${variable2}',
          result: 'keyvalueresult',
          variables: [
            { key: 'variable', value: 'value' },
            { key: 'variable2', value: 'result' }
          ]
        },
        "out-of-order expansion": {
          value: 'key$variable2$variable',
          result: 'keyresultvalue',
          variables: [
            { key: 'variable', value: 'value' },
            { key: 'variable2', value: 'result' }
          ]
        },
        "out-of-order complex expansion": {
          value: 'key${variable2}${variable}',
          result: 'keyresultvalue',
          variables: [
            { key: 'variable', value: 'value' },
            { key: 'variable2', value: 'result' }
          ]
        },
        "review-apps expansion": {
          value: 'review/$CI_COMMIT_REF_NAME',
          result: 'review/feature/add-review-apps',
          variables: [
            { key: 'CI_COMMIT_REF_NAME', value: 'feature/add-review-apps' }
          ]
        },
        "do not lazily access variables when no expansion": {
          value: 'key',
          result: 'key',
          variables: -> { raise NotImplementedError }
        },
        "lazily access variables": {
          value: 'key$variable',
          result: 'keyvalue',
          variables: -> { [{ key: 'variable', value: 'value' }] }
        },
        "simple expansion using Collection": {
          value: 'key$variable',
          result: 'keyvalue',
          variables: Gitlab::Ci::Variables::Collection.new([
            { key: 'variable', value: 'value' }
          ])
        }
      }
    end

    with_them do
      subject { expander.call(value, variables) }

      it { is_expected.to eq(result) }
    end
  end

  describe '#expand' do
    context 'table tests' do
      it_behaves_like 'common variable expansion', described_class.method(:expand)

      context 'with missing variables' do
        using RSpec::Parameterized::TableSyntax

        where do
          {
            "missing variable": {
              value: 'key$variable',
              result: 'key',
              variables: []
            },
            "complex expansions with missing variable": {
              value: 'key${variable}${variable2}',
              result: 'keyvalue',
              variables: [
                { key: 'variable', value: 'value' }
              ]
            },
            "complex expansions with missing variable for Windows": {
              value: 'key%variable%%variable2%',
              result: 'keyvalue',
              variables: [
                { key: 'variable', value: 'value' }
              ]
            }
          }
        end

        with_them do
          subject { ExpandVariables.expand(value, variables) }

          it { is_expected.to eq(result) }
        end
      end
    end

    context 'lazily inits variables' do
      let(:variables) { -> { [{ key: 'variable', value: 'result' }] } }

      subject { described_class.expand(value, variables) }

      context 'when expanding variable' do
        let(:value) { 'key$variable$variable2' }

        it 'calls block at most once' do
          expect(variables).to receive(:call).once.and_call_original

          is_expected.to eq('keyresult')
        end
      end

      context 'when no expansion is needed' do
        let(:value) { 'key' }

        it 'does not call block' do
          expect(variables).not_to receive(:call)

          is_expected.to eq('key')
        end
      end
    end
  end

  describe '#expand_existing' do
    context 'table tests' do
      it_behaves_like 'common variable expansion', described_class.method(:expand_existing)

      context 'with missing variables' do
        using RSpec::Parameterized::TableSyntax

        where do
          {
            "missing variable": {
              value: 'key$variable',
              result: 'key$variable',
              variables: []
            },
            "complex expansions with missing variable": {
              value: 'key${variable}${variable2}',
              result: 'keyvalue${variable2}',
              variables: [
                { key: 'variable', value: 'value' }
              ]
            },
            "complex expansions with missing variable for Windows": {
              value: 'key%variable%%variable2%',
              result: 'keyvalue%variable2%',
              variables: [
                { key: 'variable', value: 'value' }
              ]
            }
          }
        end

        with_them do
          subject { ExpandVariables.expand_existing(value, variables) }

          it { is_expected.to eq(result) }
        end
      end
    end

    context 'lazily inits variables' do
      let(:variables) { -> { [{ key: 'variable', value: 'result' }] } }

      subject { described_class.expand_existing(value, variables) }

      context 'when expanding variable' do
        let(:value) { 'key$variable$variable2' }

        it 'calls block at most once' do
          expect(variables).to receive(:call).once.and_call_original

          is_expected.to eq('keyresult$variable2')
        end
      end

      context 'when no expansion is needed' do
        let(:value) { 'key' }

        it 'does not call block' do
          expect(variables).not_to receive(:call)

          is_expected.to eq('key')
        end
      end
    end
  end

  describe '#possible_var_reference?' do
    context 'table tests' do
      using RSpec::Parameterized::TableSyntax

      where do
        {
          "empty value": {
            value: '',
            result: false
          },
          "normal value": {
            value: 'some value',
            result: false
          },
          "simple expansions": {
            value: 'key$variable',
            result: true
          },
          "complex expansions": {
            value: 'key${variable}${variable2}',
            result: true
          },
          "complex expansions for Windows": {
            value: 'key%variable%%variable2%',
            result: true
          }
        }
      end

      with_them do
        subject { ExpandVariables.possible_var_reference?(value) }

        it { is_expected.to eq(result) }
      end
    end
  end

  describe '#expand_variables_collection' do
    context 'when FF :variable_inside_variable is disabled' do
      let_it_be(:project_with_flag_disabled) { create(:project) }
      let_it_be(:project_with_flag_enabled) { create(:project) }

      before do
        stub_feature_flags(variable_inside_variable: [project_with_flag_enabled])
      end

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
            "out-of-order variable reference": {
              variables: [
                { key: 'variable2', value: 'key${variable}' },
                { key: 'variable', value: 'value' }
              ]
            },
            "complex expansions with raw variable": {
              variables: [
                { key: 'variable3', value: 'key_${variable}_${variable2}' },
                { key: 'variable', value: '$variable2', raw: true },
                { key: 'variable2', value: 'value2' }
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
          subject { ExpandVariables.expand_variables_collection(variables, project_with_flag_disabled) }

          it 'returns Collection' do
            is_expected.to be_an_instance_of(Gitlab::Ci::Variables::Collection)
          end

          it 'does not expand variables' do
            is_expected.to eq(variables)
          end
        end
      end
    end

    context 'when FF :variable_inside_variable is enabled' do
      let_it_be(:project_with_flag_disabled) { create(:project) }
      let_it_be(:project_with_flag_enabled) { create(:project) }

      before do
        stub_feature_flags(variable_inside_variable: [project_with_flag_enabled])
      end

      context 'table tests' do
        using RSpec::Parameterized::TableSyntax

        where do
          {
            "empty array": {
              variables: [],
              result: []
            },
            "simple expansions": {
              variables: [
                { key: 'variable', value: 'value' },
                { key: 'variable2', value: 'result' },
                { key: 'variable3', value: 'key$variable$variable2' },
                { key: 'variable4', value: 'key$variable$variable3' }
              ],
              result: [
                { key: 'variable', value: 'value' },
                { key: 'variable2', value: 'result' },
                { key: 'variable3', value: 'keyvalueresult' },
                { key: 'variable4', value: 'keyvaluekeyvalueresult' }
              ]
            },
            "complex expansion": {
              variables: [
                { key: 'variable', value: 'value' },
                { key: 'variable2', value: 'key${variable}' }
              ],
              result: [
                { key: 'variable', value: 'value' },
                { key: 'variable2', value: 'keyvalue' }
              ]
            },
            "unused variables": {
              variables: [
                { key: 'variable', value: 'value' },
                { key: 'variable2', value: 'result2' },
                { key: 'variable3', value: 'result3' },
                { key: 'variable4', value: 'key$variable$variable3' }
              ],
              result: [
                { key: 'variable', value: 'value' },
                { key: 'variable2', value: 'result2' },
                { key: 'variable3', value: 'result3' },
                { key: 'variable4', value: 'keyvalueresult3' }
              ]
            },
            "complex expansions": {
              variables: [
                { key: 'variable', value: 'value' },
                { key: 'variable2', value: 'result' },
                { key: 'variable3', value: 'key${variable}${variable2}' }
              ],
              result: [
                { key: 'variable', value: 'value' },
                { key: 'variable2', value: 'result' },
                { key: 'variable3', value: 'keyvalueresult' }
              ]
            },
            "out-of-order expansion": {
              variables: [
                { key: 'variable3', value: 'key$variable2$variable' },
                { key: 'variable', value: 'value' },
                { key: 'variable2', value: 'result' }
              ],
              result: [
                { key: 'variable2', value: 'result' },
                { key: 'variable', value: 'value' },
                { key: 'variable3', value: 'keyresultvalue' }
              ]
            },
            "out-of-order complex expansion": {
              variables: [
                { key: 'variable', value: 'value' },
                { key: 'variable2', value: 'result' },
                { key: 'variable3', value: 'key${variable2}${variable}' }
              ],
              result: [
                { key: 'variable', value: 'value' },
                { key: 'variable2', value: 'result' },
                { key: 'variable3', value: 'keyresultvalue' }
              ]
            },
            "missing variable": {
              variables: [
                { key: 'variable2', value: 'key$variable' }
              ],
              result: [
                { key: 'variable2', value: 'key$variable' }
              ]
            },
            "complex expansions with missing variable": {
              variables: [
                { key: 'variable4', value: 'key${variable}${variable2}${variable3}' },
                { key: 'variable', value: 'value' },
                { key: 'variable3', value: 'value3' }
              ],
              result: [
                { key: 'variable', value: 'value' },
                { key: 'variable3', value: 'value3' },
                { key: 'variable4', value: 'keyvalue${variable2}value3' }
              ]
            },
            "complex expansions with raw variable": {
              variables: [
                { key: 'variable3', value: 'key_${variable}_${variable2}' },
                { key: 'variable', value: '$variable2', raw: true },
                { key: 'variable2', value: 'value2' }
              ],
              result: [
                { key: 'variable', value: '$variable2', raw: true },
                { key: 'variable2', value: 'value2' },
                { key: 'variable3', value: 'key_$variable2_value2' }
              ]
            },
            "cyclic dependency causes original array to be returned": {
              variables: [
                { key: 'variable', value: '$variable2' },
                { key: 'variable2', value: '$variable3' },
                { key: 'variable3', value: 'key$variable$variable2' }
              ],
              result: [
                { key: 'variable', value: '$variable2' },
                { key: 'variable2', value: '$variable3' },
                { key: 'variable3', value: 'key$variable$variable2' }
              ]
            }
          }
        end

        with_them do
          let!(:collection) { Gitlab::Ci::Variables::Collection.new(variables) }

          subject! do
            ExpandVariables.expand_variables_collection(collection, project_with_flag_enabled)
          end

          it 'returns Collection' do
            is_expected.to be_an_instance_of(Gitlab::Ci::Variables::Collection)
          end

          it 'expands variables' do
            is_expected.to eq(result)
          end

          it 'preserves raw attribute' do
            collection.each do |v|
              k = v[:key]
              subject_item = subject.find { |sv| sv[:key] == k }
              expect(subject_item.raw).to eq(v.raw)
            end
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Variables::ExpressionParser do
  describe '.new' do
    it 'can be initialized with a value' do
      value = '${HOME}/build/'

      parser = described_class.new(value)

      expect { parser }.not_to raise_error
    end

    it 'can not be initialized without an argument' do
      expect { subject }.to raise_error(ArgumentError, /wrong number of arguments/)
    end
  end

  describe '#expand' do
    let(:collection) do
      Gitlab::Ci::Variables::Collection.new
        .append(key: 'CI_JOB_NAME', value: 'test-1')
        .append(key: 'CI_BUILD_ID', value: '1')
        .append(key: 'RAW_VAR', value: '$TEST1', raw: true)
        .append(key: 'TEST1', value: 'test-3')
        .append(key: 'TEST2', value: '$TEST1')
        .append(key: 'TEST3', value: '$$TEST1')
        .append(key: 'TEST4', value: '$$$TEST1')
        .append(key: 'TEST_EMPTY', value: '')
    end

    context 'table tests' do
      using RSpec::Parameterized::TableSyntax

      where do
        {
          "empty value": {
            value: '',
            result: '',
            keep_undefined: false
          },
          "simple expansions": {
            value: 'key$TEST1-$CI_BUILD_ID',
            result: 'keytest-3-1',
            keep_undefined: false
          },
          "complex expansion": {
            value: 'key${TEST1}-${CI_JOB_NAME}',
            result: 'keytest-3-test-1',
            keep_undefined: false
          },
          "complex expansions with raw variable": {
            value: 'key${RAW_VAR}-${CI_JOB_NAME}',
            result: 'key$TEST1-test-1',
            keep_undefined: false
          },
          "missing variable not keeping original": {
            value: 'key${MISSING_VAR}-${CI_JOB_NAME}',
            result: 'key-test-1',
            keep_undefined: false
          },
          "missing variable keeping original": {
            value: 'key${MISSING_VAR}-${CI_JOB_NAME}',
            result: 'key${MISSING_VAR}-test-1',
            keep_undefined: true
          },
          "garbled reference is maintained verbatim - 1": {
            value: 'key${%',
            result: 'key${%',
            keep_undefined: false
          },
          "garbled reference is maintained verbatim - 2": {
            value: 'key${%',
            result: 'key${%',
            keep_undefined: true
          },
          "garbled reference is maintained verbatim - 3": {
            value: 'key$',
            result: 'key$',
            keep_undefined: false
          },
          "garbled reference is maintained verbatim - 4": {
            value: 'key${%',
            result: 'key${%',
            keep_undefined: true
          },
          "garbled reference is maintained verbatim - 5": {
            value: 'key%$%',
            result: 'key%$%',
            keep_undefined: false
          },
          "garbled reference is maintained verbatim - 6": {
            value: 'key%$%',
            result: 'key%$%',
            keep_undefined: true
          },
          "escaped characters keeping undefined are resolved correctly": {
            value: 'key-$TEST1-%%HOME%%-$${HOME}',
            result: 'key-test-3-%HOME%-${HOME}',
            keep_undefined: true
          },
          "escaped characters discarding undefined are resolved correctly": {
            value: 'key-$TEST1-%%HOME%%-$${HOME}',
            result: 'key-test-3-%HOME%-${HOME}',
            keep_undefined: false
          },
          "complex escaped characters keeping undefined are resolved correctly": {
            value: 'key-$TEST2-${TEST3}-%TEST4%',
            result: 'key-$TEST1-$$TEST1-$$$TEST1',
            keep_undefined: true
          },
          "empty variable keeping undefined is resolved correctly": {
            value: '${TEST_EMPTY}',
            result: '',
            keep_undefined: true
          }
        }
      end

      with_them do
        subject { Gitlab::Ci::Variables::ExpressionParser.new(value).expand(collection, keep_undefined) }

        it 'matches expected expansion' do
          is_expected.to eq(result)
        end
      end
    end
  end
end

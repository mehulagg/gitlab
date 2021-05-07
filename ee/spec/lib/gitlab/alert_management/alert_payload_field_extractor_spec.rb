# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::AlertManagement::AlertPayloadFieldExtractor do
  let(:project) { build_stubbed(:project) }
  let(:extractor) { described_class.new(project) }
  let(:payload) { {} }
  let(:json) { Gitlab::Json.parse(Gitlab::Json.generate(payload)) }

  let(:field) { fields.first }

  subject(:fields) { extractor.extract(json) }

  describe '#extract' do
    before do
      payload.merge!(
        str: 'value',
        nested: {
          key: 'level1',
          deep: {
            key: 'level2'
          }
        },
        time: '2020-12-09T12:34:56',
        time_iso_8601_and_rfc_3339: '2021-01-27T13:01:11+00:00', # ISO 8601 and RFC 3339
        time_iso_8601: '2021-01-27T13:01:11Z', # ISO 8601
        time_iso_8601_short: '20210127T130111Z', # ISO 8601
        time_rfc_3339: '2021-01-27 13:01:11+00:00', # RFC 3339
        discarded_null: nil,
        discarded_bool_true: true,
        discarded_bool_false: false,
        arr: [
          { key_a: 'string', key_b: ['nested_arr_value'] },
          'non_hash_value',
          [['array_a'], 'array_b']
        ]
      )
    end

    it 'returns all the possible field combination and types suggestions' do
      expect(fields).to contain_exactly(
        a_field(['str'], 'str', 'string'),
        a_field(%w(nested key), 'nested/key', 'string'),
        a_field(%w(nested deep key), 'nested/deep/key', 'string'),
        a_field(['time'], 'time', 'datetime'),
        a_field(['time_iso_8601_and_rfc_3339'], 'time_iso_8601_and_rfc_3339', 'datetime'),
        a_field(['time_iso_8601'], 'time_iso_8601', 'datetime'),
        a_field(['time_iso_8601_short'], 'time_iso_8601_short', 'datetime'),
        a_field(['time_rfc_3339'], 'time_rfc_3339', 'datetime'),
        a_field(['arr'], 'arr', 'array'),
        a_field(['arr', 0, 'key_a'], 'arr[0]/key_a', 'string'),
        a_field(['arr', 0, 'key_b'], 'arr[0]/key_b', 'array'),
        a_field(['arr', 0, 'key_b', 0], 'arr[0]/key_b[0]', 'string'),
        a_field(['arr', 1], 'arr[1]', 'string'),
        a_field(['arr', 2], 'arr[2]', 'array'),
        a_field(['arr', 2, 0], 'arr[2][0]', 'array'),
        a_field(['arr', 2, 1], 'arr[2][1]', 'string'),
        a_field(['arr', 2, 0, 0], 'arr[2][0][0]', 'string')
      )
    end
  end

  private

  def a_field(path, label, type)
    have_attributes(project: project, path: path, label: label, type: type)
  end
end

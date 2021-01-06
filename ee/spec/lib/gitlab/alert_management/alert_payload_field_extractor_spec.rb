# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::AlertManagement::AlertPayloadFieldExtractor do
  let(:project) { build_stubbed(:project) }
  let(:extractor) { described_class.new(project) }
  let(:payload) { {} }
  let(:json) { Gitlab::Json.parse(Gitlab::Json.generate(payload)) }

  let(:field) { fields.first }

  subject(:fields) { extractor.extract(json) }

  context 'plain' do
    before do
      payload.merge!(
        str: 'value',
        int: 23,
        float: 23.5,
        nested: {
          key: 'level1',
          deep: {
            key: 'level2'
          }
        },
        time: '2020-12-09T12:34:56',
        discarded_null: nil,
        discarded_bool_true: true,
        discarded_bool_false: false
      )
    end

    it 'works' do
      expect(fields).to contain_exactly(
        a_field(['str'], 'Str', 'string'),
        a_field(['int'], 'Int', 'numeric'),
        a_field(['float'], 'Float', 'numeric'),
        a_field(%w(nested key), 'Key', 'string'),
        a_field(%w(nested deep key), 'Key', 'string'),
        a_field(['time'], 'Time', 'datetime')
      )
    end
  end

  private

  def a_field(path, label, type)
    have_attributes(project: project, path: path, label: label, type: type)
  end
end

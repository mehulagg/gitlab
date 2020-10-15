# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImports::Common::Transformers::GraphqlCleanerTransformer do
  describe '#transform' do
    it 'deep cleans hash from GraphQL keys' do
      data = {
        'data' => {
          'group' => {
            'name' => 'test',
            'fullName' => 'test',
            'description' => 'test',
            'labels' => {
              'edges' => [
                { 'node' => { 'title' => 'label1' } },
                { 'node' => { 'title' => 'label2' } },
                { 'node' => { 'title' => 'label3' } }
              ]
            }
          }
        }
      }

      expected_output = {
        'name' => 'test',
        'fullName' => 'test',
        'description' => 'test',
        'labels' => [
          { 'title' => 'label1' },
          { 'title' => 'label2' },
          { 'title' => 'label3' }
        ]
      }

      transformed_data = described_class.new.transform(nil, data)

      expect(transformed_data).to eq(expected_output)
    end
  end
end

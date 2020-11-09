# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BreadcrumbsHelper do
  let(:elements) do
    [
      ['element1', 'link1'],
      ['element2', 'link2']
    ]
  end

  describe '#push_to_schema_breadcrumb' do
    it 'enqueue element name, link and position' do
      enqueue_breadcrumb_elements

      list = helper.instance_variable_get(:@schema_breadcrumb_list)

      aggregate_failures do
        list.each_with_index do |el, index|
          expect(el['name']).to eq elements[index][0]
          expect(el['item']).to eq elements[index][1]
          expect(el['position']).to eq(index + 1)
        end
      end
    end
  end

  describe '#schema_breadcrumb_json' do
    it 'returns the breadcrumb schema in json format' do
      enqueue_breadcrumb_elements

      result = helper.schema_breadcrumb_json

      subelements = []
      elements.each_with_index do |el, index|
        subelements << { '@type' => 'ListItem', 'position' => index + 1, 'name' => el[0], 'item' => el[1] }
      end

      expected_result = {
        '@context' => 'https://schema.org',
        '@type' => 'BreadcrumbList',
        'itemListElement' => subelements
      }.to_json

      expect(result).to eq expected_result
    end
  end

  def enqueue_breadcrumb_elements
    elements.each do |el|
      helper.push_to_schema_breadcrumb(el[0], el[1])
    end
  end
end

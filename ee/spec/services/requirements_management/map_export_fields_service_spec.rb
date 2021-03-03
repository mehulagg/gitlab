# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RequirementsManagement::MapExportFieldsService do
  let(:selected_fields) { ['Title', 'Author username', 'state'] }
  let(:invalid_fields) { ['Title', 'Author Username', 'State', 'Invalid Field', 'Other Field'] }
  let(:available_fields) do
    [
      'Requirement ID',
      'Title',
      'Description',
      'Author',
      'Author Username',
      'Created At (UTC)',
      'State',
      'State Updated At (UTC)'
    ]
  end

  describe '#execute' do
    it 'returns a hash with selected fields only' do
      result = described_class.new(selected_fields).execute

      expect(result).to be_a(Hash)
      expect(result.keys).to match_array(selected_fields.map(&:titleize))
    end

    context 'when the fields collection is empty' do
      it 'returns a hash with all fields' do
        result = described_class.new([]).execute

        expect(result).to be_a(Hash)
        expect(result.keys).to match_array(available_fields)
      end
    end

    context 'when fields collection includes invalid fields' do
      it 'returns a hash with valid selected fields only' do
        result = described_class.new(invalid_fields).execute

        expect(result).to be_a(Hash)
        expect(result.keys).to eq(selected_fields.map(&:titleize))
      end
    end
  end

  describe '#invalid_fields' do
    it 'returns an array containing invalid fields' do
      result = described_class.new(invalid_fields).invalid_fields

      expect(result).to match_array(['Invalid Field', 'Other Field'])
    end
  end
end

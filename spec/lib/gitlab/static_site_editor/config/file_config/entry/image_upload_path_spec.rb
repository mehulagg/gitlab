# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::StaticSiteEditor::Config::FileConfig::Entry::ImageUploadPath do
  let(:image_upload_path) { described_class.new(config) }

  describe 'validations' do
    context 'when value is valid' do
      let(:config) { 'an-image-upload-path' }

      describe '#value' do
        it 'returns a image_upload_path key' do
          expect(image_upload_path.value).to eq config
        end
      end

      describe '#valid?' do
        it 'is valid' do
          expect(image_upload_path).to be_valid
        end
      end
    end

    context 'when value has a wrong type' do
      let(:config) { { not_a_string: true } }

      it 'reports errors about wrong type' do
        expect(image_upload_path.errors)
          .to include 'image upload path config should be a string'
      end
    end
  end

  describe '.default' do
    it 'returns default image_upload_path' do
      expect(described_class.default).to eq 'source/images'
    end
  end
end

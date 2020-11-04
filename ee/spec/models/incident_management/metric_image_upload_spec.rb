# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::MetricImageUpload do

  describe 'associations' do
    subject { build(:metric_image_upload) }

    it { is_expected.to belong_to(:incident) }
  end

  describe 'validation' do
    let(:txt_file) { fixture_file_upload('spec/fixtures/doc_sample.txt', 'text/plain') }
    it { is_expected_to_not allow_value(txt_file).for(:file) }
  end
end

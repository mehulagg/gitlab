# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IssuableMetricImage do
  subject { build(:issuable_metric_image) }

  describe 'associations' do
    it { is_expected.to belong_to(:issue) }
  end

  describe 'validation' do
    let(:txt_file) { fixture_file_upload('spec/fixtures/doc_sample.txt', 'text/plain') }
    let(:img_file) { fixture_file_upload('spec/fixtures/rails_sample.jpg', 'image/jpg') }

    it { is_expected.not_to allow_value(txt_file).for(:file) }
    it { is_expected.to allow_value(img_file).for(:file) }

    describe 'url' do
      it { is_expected.not_to allow_value('test').for(:url) }
      it { is_expected.not_to allow_value('www.gitlab.com').for(:url) }
      it { is_expected.to allow_value('').for(:url) }
      it { is_expected.to allow_value('http://www.gitlab.com').for(:url) }
      it { is_expected.to allow_value('https://www.gitlab.com').for(:url) }
    end
  end
end

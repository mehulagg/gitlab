# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::StatusPage::Pipeline::PostProcessPipeline do
  describe '.filters' do
    let(:expected_filters) do
      [Gitlab::StatusPage::Filter::MentionAnonymizationFilter] +
        ::Banzai::Pipeline::PostProcessPipeline.filters +
        [Gitlab::StatusPage::Filter::ImageFilter]
    end

    subject { described_class.filters }

    it { is_expected.to eq(expected_filters) }
    it { is_expected.to be_frozen }
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastSiteValidation, type: :model do
  subject { create(:dast_site_validation) }

  describe 'associations' do
    it { is_expected.to belong_to(:dast_site_token) }
    it { is_expected.to have_many(:dast_sites) }
  end

  describe 'validations' do
    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:dast_site_token_id) }
  end

  describe 'before_create' do
    it 'sets normalises the dast_site_token url' do
      uri = URI(subject.dast_site_token.url)

      expect(subject.url_base).to eq("#{uri.scheme}://#{uri.host}:#{uri.port}")
    end
  end

  describe 'scopes' do
    describe 'by_project_id' do
      let(:another_dast_site_validation) { create(:dast_site_validation) }

      it 'includes the correct records' do
        result = described_class.by_project_id(subject.dast_site_token.project_id)

        aggregate_failures do
          expect(result).to include(subject)
          expect(result).not_to include(another_dast_site_validation)
        end
      end
    end
  end

  describe 'enums' do
    let(:validation_strategies) do
      { text_file: 0 }
    end

    it { is_expected.to define_enum_for(:validation_strategy).with_values(validation_strategies) }
  end

  describe '#project' do
    it 'returns project through dast_site_token' do
      expect(subject.project).to eq(subject.dast_site_token.project)
    end
  end
end

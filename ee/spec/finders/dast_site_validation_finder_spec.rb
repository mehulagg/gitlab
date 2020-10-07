# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastSiteValidationsFinder do
  let_it_be(:dast_site_validation_1) { create(:dast_site_validation) }
  let_it_be(:dast_site_validation_2) { create(:dast_site_validation) }
  let_it_be(:dast_site_validation_3) { create(:dast_site_validation) }

  let(:params) { {} }

  subject do
    described_class.new(params).execute
  end

  describe '#execute' do
    it 'returns all dast_site_validations' do
      expect(subject).to contain_exactly(dast_site_validation_1, dast_site_validation_2, dast_site_validation_3)
    end

    context 'filtering by URL' do
      let(:params) { { urls: [dast_site_validation_1.validation_url, dast_site_validation_3.validation_url] } }

      it 'returns the dast_site_validations' do
        expect(subject).to contain_exactly(dast_site_validation_1, dast_site_validation_3)
      end
    end

    context 'filter by project' do
      let(:params) { { project_ids: [dast_site_validation_1.dast_site_token.project_id, dast_site_validation_2.dast_site_token.project_id] } }

      it 'returns the matching dast_scanner_profiles' do
        expect(subject).to contain_exactly(dast_site_validation_1, dast_site_validation_2)
      end
    end

    context 'when DastSiteValidation URL is for a different project' do
      let(:params) { { urls: [dast_site_validation_1.validation_url], project_ids: [dast_site_validation_2.dast_site_token.project_id] } }

      it 'returns an empty relation' do
        expect(subject).to be_empty
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastSiteValidationsFinder do
  let_it_be(:dast_site_validation_1) { create(:dast_site_validation) }
  let_it_be(:dast_site_validation_2) { create(:dast_site_validation) }
  let_it_be(:dast_site_validation_3) { create(:dast_site_validation, dast_site_token: dast_site_validation_1.dast_site_token) }

  let(:params) { {} }

  subject do
    described_class.new(params).execute
  end

  describe '#execute' do
    it 'returns all dast_site_validation_validations most recent first' do
      expect(subject).to eq([dast_site_validation_3, dast_site_validation_2, dast_site_validation_1])
    end

    context 'filtering by most_recent' do
      let(:params) { { most_recent: true } }

      it 'returns the matching dast_site_validations' do
        expect(subject).to eq([dast_site_validation_3, dast_site_validation_2])
      end

      it 'allows the results to be easily re-ordered' do
        relation = subject.reorder(id: :asc)

        expect(relation).to eq([dast_site_validation_2, dast_site_validation_3])
      end
    end

    context 'filtering by project_id' do
      let(:params) { { project_id: dast_site_validation_2.project.id } }

      it 'returns the matching dast_site_validations' do
        expect(subject).to eq([dast_site_validation_2])
      end

      context 'when url_base is for a different project' do
        let(:params) { { project_id: dast_site_validation_2.project.id, url_base: dast_site_validation_1.url_base } }

        it 'returns an empty relation' do
          expect(subject).to be_empty
        end
      end
    end

    context 'filtering by url_base' do
      let(:params) { { url_base: dast_site_validation_1.url_base } }

      it 'returns the matching dast_site_validations' do
        expect(subject).to eq([dast_site_validation_3, dast_site_validation_1])
      end
    end

    context 'filtering by *' do
      let(:params) { { project_id: dast_site_validation_1.project.id, url_base: dast_site_validation_1.url_base, most_recent: true } }

      it 'returns the matching dast_site_validations' do
        expect(subject).to eq([dast_site_validation_3])
      end
    end
  end
end

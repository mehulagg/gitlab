# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastSiteValidations::RevokeService do
  let_it_be(:project) { create(:project) }
  let_it_be(:dast_site_token) { create(:dast_site_token, project: project) }
  let_it_be(:dast_site_validation1) { create(:dast_site_validation, state: :passed, dast_site_token: dast_site_token) }
  let_it_be(:dast_site_validation2) { create(:dast_site_validation, state: :passed, dast_site_token: dast_site_token) }
  let_it_be(:dast_site_validation3) { create(:dast_site_validation, state: :failed, dast_site_token: dast_site_token) }
  let_it_be(:dast_site_validation4) { create(:dast_site_validation, state: :passed) }
  let_it_be(:dast_site_validation5) { create(:dast_site_validation, state: :inprogress) }

  let(:params) { { url_base: dast_site_validation1.url_base } }

  subject { described_class.new(container: project, params: params).execute }

  describe 'execute', :clean_gitlab_redis_shared_state do
    context 'when on demand scan licensed feature is not available' do
      it 'communicates failure' do
        stub_licensed_features(security_on_demand_scans: false)

        aggregate_failures do
          expect(subject.status).to eq(:error)
          expect(subject.message).to eq('Insufficient permissions')
        end
      end
    end

    context 'when the feature is enabled' do
      before do
        stub_licensed_features(security_on_demand_scans: true)
      end

      it 'communicates success' do
        expect(subject.status).to eq(:success)
      end

      it 'deletes dast_site_validations where state=passed' do
        aggregate_failures do
          expect { subject }.to change { DastSiteValidation.count }.from(5).to(3)

          expect { dast_site_validation1.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect { dast_site_validation2.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      it 'returns a count of the dast_site_validations that were deleted' do
        expect(subject.payload[:count]).to eq(2)
      end

      context 'when the finder does not find any dast_site_validations' do
        let_it_be(:project) { create(:project) }

        it 'communicates success' do
          expect(subject.status).to eq(:success)
        end

        it 'is a noop' do
          aggregate_failures do
            expect(subject.payload[:count]).to be_zero

            expect { subject }.not_to change { DastSiteValidation.count }
          end
        end
      end

      context 'when a param is missing' do
        let(:params) { {} }

        it 'communicates failure' do
          aggregate_failures do
            expect(subject.status).to eq(:error)
            expect(subject.message).to eq('URL parameter used to search for validations is missing')
          end
        end
      end
    end
  end
end

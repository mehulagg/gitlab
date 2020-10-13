# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::DastSiteValidations::Create do
  let(:group) { create(:group) }
  let(:project) { dast_site_token.project }
  let(:user) { create(:user) }
  let(:full_path) { project.full_path }
  let(:dast_site_token) { create(:dast_site_token, project: create(:project, group: group)) }
  let(:dast_site_validation) { DastSiteValidation.first! }

  subject(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }

  before do
    stub_licensed_features(security_on_demand_scans: true)
  end

  describe '#resolve' do
    subject do
      mutation.resolve(
        full_path: full_path,
        dast_site_token_id: dast_site_token.to_global_id,
        validation_path: '/path/to/the/file.txt',
        strategy: :text_file
      )
    end

    context 'when on demand scan feature is enabled' do
      context 'when the project does not exist' do
        let(:full_path) { SecureRandom.hex }

        it 'raises an exception' do
          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'when the user is not associated with the project' do
        it 'raises an exception' do
          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'when the user is an owner' do
        it 'returns the dast_site_validation id' do
          group.add_owner(user)

          expect(subject[:id]).to eq(dast_site_validation.to_global_id)
        end
      end

      context 'when the user is a maintainer' do
        it 'returns the dast_site_validation id' do
          project.add_maintainer(user)

          expect(subject[:id]).to eq(dast_site_validation.to_global_id)
        end
      end

      context 'when the user can run a dast scan' do
        before do
          project.add_developer(user)
        end

        it 'returns the dast_site_validation id' do
          expect(subject[:id]).to eq(dast_site_validation.to_global_id)
        end

        it 'returns the dast_site_validation status' do
          expect(subject[:status]).to eq('PENDING_VALIDATION')
        end

        context 'when the associated dast_site_validation has been validated' do
          it 'returns the correct status' do
            # does something...
          end
        end

        context 'when on demand scan feature is not enabled' do
          it 'raises an exception' do
            stub_feature_flags(security_on_demand_scans_feature_flag: false)

            expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
          end
        end

        context 'when on demand scan site validations feature is not enabled' do
          it 'raises an exception' do
            stub_feature_flags(security_on_demand_scans_site_validation: false)

            expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
          end
        end

        context 'when on demand scan licensed feature is not available' do
          it 'raises an exception' do
            stub_licensed_features(security_on_demand_scans: false)

            expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
          end
        end
      end
    end
  end
end

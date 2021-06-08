# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::Minutes::AdditionalPacks::CreateService do
  describe '#execute' do
    let_it_be(:namespace) { create(:namespace) }
    let_it_be(:admin) { build(:admin) }
    let_it_be(:non_admin) { build(:user) }

    let(:params) { {} }

    subject(:result) { described_class.new(user, namespace, params).execute }

    context 'with a non-admin user' do
      let(:user) { non_admin }

      it 'raises an error' do
        expect { result }.to raise_error(Gitlab::Access::AccessDeniedError)
      end
    end

    context 'with an admin user' do
      let(:existing_pack) { create(:ci_minutes_additional_pack, namespace: namespace) }
      let(:user) { admin }

      context 'when a record exists' do
        let(:params) do
          {
            expires_at: Date.today + 1.year,
            purchase_xid: existing_pack.purchase_xid,
            number_of_minutes: 10_000
          }
        end

        it 'returns success' do
          expect(result[:status]).to eq :success
        end

        it 'returns the existing record' do
          expect(result[:additional_pack]).to eq existing_pack
        end
      end

      context 'when no record exists' do
        let(:params) do
          {
            expires_at: Date.today + 1.year,
            purchase_xid: 'new-purchase-xid',
            number_of_minutes: 10_000
          }
        end

        it 'creates a new record' do
          expect { result }.to change(Ci::Minutes::AdditionalPack, :count).by(1)
        end

        it 'returns success' do
          expect(result[:status]).to eq :success
        end

        context 'with invalid params' do
          let(:params) { { purchase_xid: 'missing-minutes' } }

          it 'returns an error', :aggregate_failures do
            response = result

            expect(response[:status]).to eq :error
            expect(response[:http_status]).to eq 422
            expect(response[:message]).to eq 'Unable to save additional pack'
          end
        end
      end
    end
  end
end

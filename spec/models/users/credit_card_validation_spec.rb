# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Users::CreditCardValidation do
  it { is_expected.to belong_to(:user) }

  describe '#credit_card_validated_at=' do
    shared_examples 'does not change credit card validation count' do
      it 'does not change credit card validation count' do
        expect { subject }.not_to change { described_class.count }
      end
    end

    subject { cc_validation.credit_card_validated_at = val }

    context 'when record is persisted' do
      let!(:cc_validation) { create(:credit_card_validation) }

      context 'when passing in "1"' do
        let(:val) { "1" }

        it 'does not update credit_card_validated_at' do
          expect { subject }.not_to change { cc_validation.credit_card_validated_at }
        end
      end

      context 'when passing in "0"' do
        let(:val) { "0" }

        it 'destroys self' do
          expect { subject }.to change { described_class.count }.by(-1)
        end
      end

      context 'when passing in "foo"' do
        let(:val) { "foo" }

        include_examples 'does not change credit card validation count'
      end
    end

    context 'when record is not persisted' do
      let(:cc_validation) { build(:credit_card_validation) }

      context 'when passing in "1"' do
        let(:val) { "1" }

        it 'sets credit_card_validated_at' do
          freeze_time do
            subject

            expect(cc_validation.credit_card_validated_at).to eq(Time.zone.now)
          end
        end
      end

      context 'when passing in "0"' do
        let(:val) { "0" }

        include_examples 'does not change credit card validation count'
      end

      context 'when passing in "foo"' do
        let(:val) { "foo" }

        include_examples 'does not change credit card validation count'
      end
    end
  end
end

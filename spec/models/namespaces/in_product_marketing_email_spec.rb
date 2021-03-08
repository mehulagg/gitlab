# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Namespaces::InProductMarketingEmail, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:namespace) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    subject { build(:in_product_marketing_email) }

    it { is_expected.to validate_presence_of(:namespace) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:track) }
    it { is_expected.to validate_presence_of(:series) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to([:track, :series]).with_message('has already been sent') }
  end

  describe '#track_cta_click' do
    let(:in_product_marketing_email) { create(:in_product_marketing_email) }

    subject(:cta_clicked) { in_product_marketing_email.cta_clicked }

    it 'saves the cta click date' do
      expect(in_product_marketing_email.cta_clicked_at).to be_nil

      freeze_time do
        cta_clicked

        expect(described_class.last.cta_clicked_at).to eq(Time.zone.now)
      end
    end
  end
end

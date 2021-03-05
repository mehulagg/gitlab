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
end

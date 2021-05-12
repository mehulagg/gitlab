# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Users::AuthorizedBuildService do
  describe '#execute' do
    let_it_be(:user) { create(:user) }

    let(:params) { build_stubbed(:user).slice(:first_name, :last_name, :username, :email, :password) }

    subject(:built_user) { described_class.new(user, params).execute }

    it { is_expected.to be_valid }

    it 'sets the created_by_id' do
      expect(built_user.created_by_id).to eq(user.id)
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SamlGroupLink do
  describe 'associations' do
    it { is_expected.to belong_to(:group) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:group) }
    it { is_expected.to validate_presence_of(:access_level) }
    it { is_expected.to validate_presence_of(:saml_group_name) }
    it { is_expected.to validate_length_of(:saml_group_name).is_at_most(255) }
    it { is_expected.to define_enum_for(:access_level).with_values(Gitlab::Access.options_with_owner) }

    context 'group name uniqueness' do
      before do
        create(:saml_group_link, group: create(:group))
      end

      it { is_expected.to validate_uniqueness_of(:saml_group_name).scoped_to([:group_id]) }
    end
  end
end

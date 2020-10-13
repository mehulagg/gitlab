# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SamlGroupLink do
  describe 'associations' do
    it { is_expected.to belong_to(:group) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:group) }
    it { is_expected.to validate_presence_of(:access_level) }
    it { is_expected.to validate_presence_of(:group_name) }
    it { is_expected.to validate_inclusion_of(:access_level).in_array([*Gitlab::Access.all_values]) }
    it { is_expected.to validate_length_of(:group_name).is_at_most(255) }

    context 'group name uniqueness' do
      let_it_be(:group_link) { create(:saml_group_link, group: create(:group)) }

      it { is_expected.to validate_uniqueness_of(:group_name).scoped_to([:group_id]) }
    end
  end
end

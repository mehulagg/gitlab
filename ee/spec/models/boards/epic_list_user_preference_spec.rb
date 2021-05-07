# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Boards::EpicListUserPreference do
  let_it_be(:user) { create(:user) }
  let_it_be(:epic_list) { create(:epic_list) }

  before do
    epic_list.update_preferences_for(user, { collapsed: true })
  end

  describe 'relationships' do
    it { is_expected.to belong_to(:epic_list) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to validate_presence_of(:epic_list) }
    it { is_expected.to validate_presence_of(:user) }

    it do
      is_expected.to validate_uniqueness_of(:user_id).scoped_to(:epic_list_id)
                       .with_message("should have only one epic list preference per user")
    end
  end
end

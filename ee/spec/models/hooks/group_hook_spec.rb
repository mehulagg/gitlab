# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GroupHook do
  describe 'associations' do
    it { is_expected.to belong_to :group }
  end

  it_behaves_like 'includes Limitable concern' do
    subject { build(:group_hook, group: create(:group)) }
  end
end

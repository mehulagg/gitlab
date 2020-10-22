# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EpicUserMention do
  describe 'associations' do
    it { is_expected.to belong_to(:epic) }
    it { is_expected.to belong_to(:note) }
  end

  it_behaves_like 'has user mentions'
end

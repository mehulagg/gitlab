# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Quality::TestCase do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }

  describe 'associations' do
    subject { build(:quality_test_case) }

    it { is_expected.to belong_to(:project) }
  end

  describe 'validations' do
    subject { build(:quality_test_case) }

    it { is_expected.to validate_presence_of(:project) }
    it { is_expected.to validate_presence_of(:title) }

    it { is_expected.to validate_length_of(:title).is_at_most(::Issuable::TITLE_LENGTH_MAX) }
    it { is_expected.to validate_length_of(:title_html).is_at_most(::Issuable::TITLE_HTML_LENGTH_MAX) }
  end
end

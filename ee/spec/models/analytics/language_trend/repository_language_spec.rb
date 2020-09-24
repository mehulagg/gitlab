# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::LanguageTrend::RepositoryLanguage do
  describe 'associations' do
    it { is_expected.to belong_to(:programming_language) }
    it { is_expected.to belong_to(:project) }
  end
end

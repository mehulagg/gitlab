# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::RepositoryStorageMove, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:container).class_name('Group') }
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::ReindexingSlice, type: :model do
  describe 'relations' do
    it { is_expected.to belong_to(:elastic_reindexing_subtask) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:elastic_slice) }
    it { is_expected.to validate_presence_of(:elastic_max_slice) }
    it { is_expected.to validate_presence_of(:retry_attempt) }
    it { is_expected.to  validate_numericality_of(:retry_attempt).is_greater_than_or_equal_to(0) }
    it { is_expected.to  validate_numericality_of(:elastic_slice).is_greater_than_or_equal_to(0) }
    it { is_expected.to  validate_numericality_of(:elastic_max_slice).is_greater_than_or_equal_to(0) }
  end
end

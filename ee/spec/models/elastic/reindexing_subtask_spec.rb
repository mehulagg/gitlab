# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::ReindexingSubtask, type: :model do
  describe 'relations' do
    it { is_expected.to belong_to(:elastic_reindexing_task) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:index_name_from) }
    it { is_expected.to validate_presence_of(:index_name_to) }
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BoardAssignee do
  describe 'relationships' do
    it { is_expected.to belong_to(:board) }
    it { is_expected.to belong_to(:assignee).class_name('User') }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:board) }
    it { is_expected.to validate_presence_of(:assignee) }
  end
end

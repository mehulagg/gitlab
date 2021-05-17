# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SlackIntegration do
  describe "Associations" do
    it { is_expected.to belong_to(:integration) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:team_id) }
    it { is_expected.to validate_presence_of(:team_name) }
    it { is_expected.to validate_presence_of(:alias) }
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:integration) }
  end
end

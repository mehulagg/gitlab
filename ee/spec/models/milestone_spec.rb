# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Milestone do
  describe "Associations" do
    it { is_expected.to have_many(:boards) }
  end
end

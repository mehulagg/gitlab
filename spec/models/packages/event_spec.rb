# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Packages::Event, type: :model do
  describe 'relationships' do
    it { is_expected.to belong_to(:package).optional }
    it { is_expected.to belong_to(:container_repository).optional }
  end
end

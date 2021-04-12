# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Clusters::Integrations::Prometheus do
  describe 'associations' do
    it { is_expected.to belong_to(:cluster).class_name('Clusters::Cluster') }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:cluster) }
  end
end

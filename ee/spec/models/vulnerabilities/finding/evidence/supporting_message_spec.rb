# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::Finding::Evidence::SupportingMessage do
  it { is_expected.to belong_to(:evidence).class_name('Vulnerabilities::Finding::Evidence').inverse_of(:supporting_message).required }

  it { is_expected.to validate_length_of(:name).is_at_most(2048) }
  it { is_expected.to validate_presence_of(:name) }
end

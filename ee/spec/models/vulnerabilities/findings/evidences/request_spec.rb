# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::Findings::Evidences::Request do
  it { is_expected.to belong_to(:evidence).class_name('Vulnerabilities::Findings::Evidence').inverse_of(:request).required }

  it { is_expected.to validate_length_of(:method).is_at_most(32) }
  it { is_expected.to validate_length_of(:url).is_at_most(2048) }
  it { is_expected.to validate_length_of(:body).is_at_most(2048) }
end

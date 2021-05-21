# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::Finding::Evidence::Response do
  it { is_expected.to belong_to(:evidence).class_name('Vulnerabilities::Finding::Evidence').inverse_of(:response).required }

  it { is_expected.to validate_length_of(:reason_phrase).is_at_most(2048) }
  it { is_expected.to validate_length_of(:body).is_at_most(2048) }
end

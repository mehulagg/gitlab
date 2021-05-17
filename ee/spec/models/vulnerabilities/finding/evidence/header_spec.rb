# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::Finding::Evidence::Header do
  it { is_expected.to belong_to(:request).class_name('Vulnerabilities::Finding::Evidence::Request').inverse_of(:headers).optional }
  it { is_expected.to belong_to(:response).class_name('Vulnerabilities::Finding::Evidence::Response').inverse_of(:headers).optional }

  it { is_expected.to validate_length_of(:name).is_at_most(255) }
end

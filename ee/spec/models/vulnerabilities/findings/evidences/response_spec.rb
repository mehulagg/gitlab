# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::Findings::Evidences::Response do
  it { is_expected.to belong_to(:evidence).class_name('Vulnerabilities::Findings::Evidence').inverse_of(:response).required }
end

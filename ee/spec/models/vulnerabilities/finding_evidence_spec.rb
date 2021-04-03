# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::FindingEvidence do
  it { is_expected.to belong_to(:finding).class_name('Vulnerabilities::Finding').required }
end

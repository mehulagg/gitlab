# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['SecurityScannerType'] do
  it 'exposes all security scanner types' do
    expect(described_class.values.keys).to contain_exactly(*%w[CONTAINER_SCANNING COVERAGE_FUZZING DAST DEPENDENCY_SCANNING SAST SECRET_DETECTION])
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['TestReportState'] do
  it 'exposes all the possible test report states' do
    expect(described_class.values.keys).to contain_exactly(*%w[PASSED FAILED])
  end
end

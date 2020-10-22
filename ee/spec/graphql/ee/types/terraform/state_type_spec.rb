# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['TerraformState'] do
  describe 'fields' do
    it { expect(described_class.fields['versions'].type).to be_non_null }
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe UserDetail do
  it { is_expected.to belong_to(:provisioned_by_group) }
end

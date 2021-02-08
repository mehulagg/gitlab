# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vault::Setting do
  it { is_expected.to belong_to(:project).required }

  it { is_expected.to validate_length_of(:server_url).is_at_most(2047) }
  it { is_expected.to validate_length_of(:auth_role).is_at_most(255).allow_nil }
  it { is_expected.to validate_length_of(:auth_path).is_at_most(255).allow_nil }

  it { is_expected.to nullify_if_blank(:auth_role) }
  it { is_expected.to nullify_if_blank(:auth_path) }
end

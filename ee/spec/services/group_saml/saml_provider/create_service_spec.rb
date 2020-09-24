# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GroupSaml::SamlProvider::CreateService do
  let(:current_user) { build_stubbed(:user) }
  subject(:service) { described_class.new(current_user, group, params: params) }

  let(:group) { create :group }

  include_examples 'base SamlProvider service'
end

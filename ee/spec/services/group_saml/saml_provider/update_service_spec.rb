# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GroupSaml::SamlProvider::UpdateService do
  let(:current_user) { create(:user) }
  subject(:service) { described_class.new(current_user, saml_provider, params: params) }

  let(:saml_provider) do
    create :saml_provider, enabled: false, enforced_sso: false
  end

  let(:group) { saml_provider.group }

  include_examples 'base SamlProvider service'
  include_examples 'SamlProvider service toggles Group Managed Accounts'
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Todos::Create do
  include GraphqlHelpers

  context 'with epics as target' do
    before do
      stub_licensed_features(epics: true)
    end

    it_behaves_like 'create todo mutation' do
      let_it_be(:group) { create(:group, :private) }
      let_it_be(:target) { create(:epic, group: group) }
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::RegistrationsHelper do
  using RSpec::Parameterized::TableSyntax

  describe '#visibility_level_options' do
    let(:user) { build(:user) }

    before do
      allow(helper).to receive(:current_user).and_return(user)
      assign(:group, Group.new)
    end

    it 'returns the desired mapping' do
      expect(helper.visibility_level_options).to eq [
        { level: 0, label: 'Private', description: 'The group and its projects can only be viewed by members.' },
        { level: 10, label: 'Internal', description: 'The group and any internal projects can be viewed by any logged in user except external users.' },
        { level: 20, label: 'Public', description: 'The group and any public projects can be viewed without any authentication.' }
      ]
    end
  end
end

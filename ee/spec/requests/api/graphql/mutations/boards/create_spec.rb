# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Boards::Create do
  let_it_be(:parent) { create(:group) }

  let(:group_path) { parent.full_path }
  let(:params) do
    {
      group_path: group_path,
      name: name
    }
  end

  it_behaves_like 'boards create mutation'
end

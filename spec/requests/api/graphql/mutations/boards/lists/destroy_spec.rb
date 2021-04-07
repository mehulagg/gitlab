# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Boards::Lists::Destroy do
  include GraphqlHelpers

  it_behaves_like 'board lists destroy request' do
    let_it_be(:project, reload: true) { create(:project) }
    let_it_be(:board) { create(:board, project: project) }
    let_it_be(:list) { create(:list, board: board) }
    let(:klass) { List }
  end
end

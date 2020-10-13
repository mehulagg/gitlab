# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Iteration do
  let_it_be(:project) { create(:project) }
  let_it_be(:group) { create(:group) }

  it_behaves_like 'a timebox', :iteration do
    let(:timebox_args) { [:skip_project_validation] }
    let(:timebox_table_name) { described_class.table_name.to_sym }
  end
end

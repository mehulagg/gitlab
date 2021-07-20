# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dast::BranchPolicy do
  it_behaves_like 'a dast on-demand scan policy' do
    let_it_be(:record) { Dast::Branch.new(create(:dast_profile, project: project)) }
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::PackageDetailsResolver do
  include GraphqlHelpers

  let_it_be(:user) { create(:user) }
  let_it_be_with_reload(:project) { create(:project) }
  let_it_be(:package) { create(:composer_package, project: project) }

  describe '#resolve' do
    let(:args) do
      { id: package.to_global_id.to_s }
    end

    subject { resolve(described_class, ctx: { current_user: user }, args: args).sync }

    context 'with authorized user' do
      before do
        project.add_user(user, :maintainer)
      end

      it { is_expected.to eq(package) }
    end
  end
end

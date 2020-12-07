# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Ci::CiCdSettingResolver do
  include GraphqlHelpers

  let_it_be(:project) { create(:project) }
  let_it_be(:current_user) { create(:user) }

  subject(:resolved_settings) { resolve(described_class, obj: obj, ctx: { current_user: current_user }) }

  describe '#resolve' do
    context 'when object is not a project' do
      let(:obj) { current_user }

      it { expect(resolved_settings).to eq nil }
    end

    context 'when object is a project' do
      let(:obj) { project }

      it { expect(resolved_settings).to eq project.ci_cd_settings }
    end

    context 'when object is nil' do
      let(:obj) { nil }
      
      it { expect(resolved_settings).to eq nil}
    end
  end
end

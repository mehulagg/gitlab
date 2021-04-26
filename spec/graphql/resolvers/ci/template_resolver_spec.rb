# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Ci::TemplateResolver do
  include GraphqlHelpers

  describe '#resolve' do
    let(:user) { create(:user) }
    let(:project) { create(:project) }

    subject(:resolve_subject) { resolve(described_class, obj: project, ctx: { current_user: user }, args: { name: template_name }) }

    context 'when template exists' do
      let(:template_name) { 'Android' }

      it 'returns the found template' do
        expect(resolve_subject).to be_an_instance_of(Gitlab::Template::GitlabCiYmlTemplate)
      end
    end

    context 'when template does not exist' do
      let(:template_name) { 'invalidname' }

      it 'returns nil' do
        expect(resolve_subject).to eq(nil)
    end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::EE::API::Entities::Project do
  let(:project) { create(:project) }

  let(:entity) do
    ::API::Entities::Project.new(project)
  end

  subject { entity.as_json }

  context 'compliance_frameworks' do
    context 'when project has a compliance framework' do
      let(:project) { create(:project, :with_sox_compliance_framework) }

      it 'is an array containing a single compliance framework' do
        expect(subject[:compliance_frameworks]).to contain_exactly('SOX')
      end
    end

    context 'when project has no compliance framework' do
      let(:project) { create(:project) }

      it 'is empty array when project has no compliance framework' do
        expect(subject[:compliance_frameworks]).to eq([])
      end
    end
  end
end

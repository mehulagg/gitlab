# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImports::Configs do
  describe '.config_for' do
    context 'when portable is group' do
      it 'returns group config' do
        expect(described_class.config_for(build(:group))).to be_instance_of(BulkImports::Configs::GroupConfig)
      end
    end

    context 'when portable is project' do
      it 'returns project config' do
        expect(described_class.config_for(build(:project))).to be_instance_of(BulkImports::Configs::ProjectConfig)
      end
    end
  end
end

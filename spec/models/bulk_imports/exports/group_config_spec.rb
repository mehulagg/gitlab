# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImports::Exports::GroupConfig do
  let_it_be(:exportable) { create(:group) }

  subject { described_class.new(exportable) }

  describe '#exportable_tree' do
    it 'returns exportable project structure' do
      config = ::Gitlab::ImportExport::Config.new(config: ::Gitlab::ImportExport.group_config_file).to_h
      expected = ::Gitlab::ImportExport::AttributesFinder.new(config: config).find_root(:group)

      expect(subject.exportable_tree).to eq(expected)
    end
  end

  describe '#export_path' do
    it 'returns correct export path' do
      expect(subject.export_path).to eq(exportable.full_path)
    end
  end

  describe '#validate_user_permissions' do
    let(:user) { create(:user) }

    context 'when user cannot admin project' do
      it 'returns false' do
        expect { subject.validate_user_permissions(user) }.to raise_error(Gitlab::ImportExport::Error)
      end
    end

    context 'when user can admin project' do
      before do
        exportable.add_owner(user)
      end

      it 'returns true' do
        expect(subject.validate_user_permissions(user)).to eq(true)
      end
    end
  end
end

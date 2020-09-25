# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ImportEntity, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:bulk_import).required }
    it { is_expected.to belong_to(:parent) }
    it { is_expected.to belong_to(:group) }
    it { is_expected.to belong_to(:project) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.to validate_presence_of(:source_full_path) }
    it { is_expected.to validate_presence_of(:destination_name) }
    it { is_expected.to validate_presence_of(:destination_full_path) }

    it { is_expected.to define_enum_for(:type).with_values(%i[group_import project_import]) }

    context 'when associated with a group and project' do
      it 'is invalid' do
        import_entity = build(:import_entity, group: build(:group), project: build(:project))

        expect(import_entity).not_to be_valid
        expect(import_entity.errors).to include(:project, :group)
      end
    end

    context 'when not associated with a group or project' do
      it 'is valid' do
        import_entity = build(:import_entity, group: nil, project: nil)

        expect(import_entity).to be_valid
      end
    end

    context 'when associated with a group and no project' do
      it 'is valid' do
        import_entity = build(:import_entity, group: build(:group), project: nil)

        expect(import_entity).to be_valid
      end
    end

    context 'when associated with a project and no group' do
      it 'is valid' do
        import_entity = build(:import_entity, group: nil, project: build(:project))

        expect(import_entity).to be_valid
      end
    end

    context 'when the parent is a group import' do
      it 'is valid' do
        import_entity = build(:import_entity, parent: build(:import_entity, :group_import))

        expect(import_entity).to be_valid
      end
    end

    context 'when the parent is a project import' do
      it 'is invalid' do
        import_entity = build(:import_entity, parent: build(:import_entity, :project_import))

        expect(import_entity).not_to be_valid
        expect(import_entity.errors).to include(:parent)
      end
    end
  end
end

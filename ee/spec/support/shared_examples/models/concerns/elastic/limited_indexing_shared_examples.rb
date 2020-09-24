# frozen_string_literal: true

RSpec.shared_examples 'limited indexing is enabled' do
  let_it_be(:project) { create :project, :repository, name: 'test1' }

  before do
    stub_ee_application_setting(elasticsearch_limit_indexing: true)
  end

  context 'when the project is not enabled specifically' do
    describe '#searchable?' do
      it 'returns false' do
        expect(object.searchable?).to be_falsey
      end
    end
  end

  context 'when a project is enabled specifically' do
    before do
      create :elasticsearch_indexed_project, project: project
    end

    describe '#searchable?' do
      it 'returns true' do
        expect(object.searchable?).to be_truthy
      end
    end
  end

  context 'when a group is enabled' do
    before do
      create :elasticsearch_indexed_namespace, namespace: group
    end

    describe '#searchable?' do
      it 'returns true' do
        expect(group_object.searchable?).to be_truthy
      end
    end
  end
end

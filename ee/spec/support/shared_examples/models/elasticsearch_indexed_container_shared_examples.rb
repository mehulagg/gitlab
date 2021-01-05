# frozen_string_literal: true

RSpec.shared_examples 'an elasticsearch indexed container' do
  describe 'validations' do
    subject { create(container, container_attributes) }

    it 'validates uniqueness of main attribute' do
      is_expected.to validate_uniqueness_of(required_attribute)
    end
  end

  describe 'callbacks' do
    subject { build(container, container_attributes) }

    describe 'on save' do
      it 'triggers index_project' do
        is_expected.to receive(:index)

        subject.save!
      end

      it 'performs the expected action' do
        index_action

        subject.save!
      end
    end

    describe 'on destroy' do
      subject { create(container, container_attributes) }

      it 'triggers delete_from_index' do
        is_expected.to receive(:delete_from_index)

        subject.destroy!
      end

      it 'performs the expected action' do
        delete_action

        subject.destroy!
      end
    end
  end
end

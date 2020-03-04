# frozen_string_literal: true

RSpec.shared_examples 'cluster application data specs' do |application_name|
  describe '#helmfile_configuration' do
    let(:application) { create(application_name) }

    subject { application.helmfile_configuration }

    shared_examples 'generating helmfile configuration file' do |installed|
      it do
        expect(subject).to include(
          application.helmfile_application_name => hash_including('installed' => installed)
        )
      end
    end

    context 'application is installing' do
      let(:application) { create(application_name) }

      include_examples 'generating helmfile configuration file', true
    end

    context 'application is not persisted' do
      let(:application) { build(application_name) }

      include_examples 'generating helmfile configuration file', false
    end
  end
end

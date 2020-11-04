# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '/Users/gosia/gitlab-development-kit/gitlab/db/post_migrate/20201104124300_ensure_namespace_settings_creation.rb')

RSpec.describe EnsureNamespaceSettingsCreation do
  context 'when there are namespaces without namespace settings' do
    let(:namespaces) { table(:namespaces) }
    let(:namespace_settings) { table(:namespace_settings) }
    let!(:namespace) { namespaces.create!(name: 'gitlab', path: 'gitlab-org') }

    it 'migrates namespaces without namespace_settings' do
      expect { migrate! }.to change { namespace_settings.count }.from(0).to(1)
    end
  end
end

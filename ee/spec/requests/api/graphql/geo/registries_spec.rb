# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Gets registries' do
  it_behaves_like 'gets registries for', {
    field_name: 'packageFileRegistries',
    registry_class_name: 'PackageFileRegistry',
    registry_factory: :geo_package_file_registry,
    registry_foreign_key_field_name: 'packageFileId'
  }

  it_behaves_like 'gets registries for', {
    field_name: 'terraformStateRegistries',
    registry_class_name: 'TerraformStateRegistry',
    registry_factory: :geo_terraform_state_registry,
    registry_foreign_key_field_name: 'terraformStateId'
  }
end

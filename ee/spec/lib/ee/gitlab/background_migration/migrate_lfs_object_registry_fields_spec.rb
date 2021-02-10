# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::Gitlab::BackgroundMigration::MigrateLfsObjectRegistryFields, :migration, :geo, schema: 20210208221816 do
  let(:registry) { table(:lfs_object_registry) }

  before do
    @foo = registry.create!(lfs_object_id: 55)
  end

  it 'works' do
    expect(@foo.created_at).not_to be_nil
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::BackgroundMigration::RemoveOrphanServiceHooks, schema: 20201117054609 do
  let(:web_hooks) { table(:web_hooks) }
  let(:services) { table(:services) }

  before do
    services.create!
    web_hooks.create!(service_id: services.first.id, type: 'ServiceHook')
    web_hooks.create!(service_id: nil)

    schema_migrate_down!
    web_hooks.create!(service_id: non_existing_record_id, type: 'ServiceHook')
    schema_migrate_up!
  end

  it 'removes service hooks with service_id but the reference does not exist', :aggregate_failures do
    expect { described_class.new.perform }.to change { web_hooks.count }.by(-1)
    expect(web_hooks.where.not(service_id: services.select(:id)).count).to eq(0)
  end
end

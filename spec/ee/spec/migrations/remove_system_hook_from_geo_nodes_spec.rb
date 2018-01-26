require 'spec_helper'
require Rails.root.join('ee', 'db', 'post_migrate', '20170811082658_remove_system_hook_from_geo_nodes.rb')

describe RemoveSystemHookFromGeoNodes, :migration do
  let(:geo_nodes) { table(:geo_nodes) }

  before do
    allow_any_instance_of(WebHookService).to receive(:execute)

    node_attrs = {
      schema: 'http',
      host: 'localhost',
      port: 3000
    }

    create(:system_hook)
    hook_id = create(:system_hook).id

    geo_nodes.create!(node_attrs.merge(primary: true))
    geo_nodes.create!(node_attrs.merge(system_hook_id: hook_id, port: 3001))
  end

  it 'destroy all system hooks for secondary nodes' do
    expect do
      migrate!
    end.to change { SystemHook.count }.by(-1)
  end
end

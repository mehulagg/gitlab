# frozen_string_literal: true

class CreateElasticSettings < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  class ElasticSetting < ActiveRecord::Base
  end

  class ApplicationSetting < ActiveRecord::Base
  end

  def up
    create_table :elastic_settings, id: false do |t|
      t.integer :id, primary_key: true, null: false, default: 1 # we only want to allow 1 row in this table

      t.jsonb :number_of_replicas, null: false
      t.jsonb :number_of_shards, null: false

      t.timestamps_with_timezone null: false
    end

    setting = ApplicationSetting.first
    number_of_replicas = setting&.elasticsearch_replicas || 1
    number_of_shards = setting&.elasticsearch_shards || 5

    ElasticSetting.create(
      number_of_replicas: { default: number_of_replicas },
      number_of_shards: { default: number_of_shards }
    )
  end

  def down
    drop_table :elastic_settings
  end
end

---
stage: Enablement
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Geo self-service framework

NOTE:
This document is subject to change as we continue to implement and iterate on the framework.
Follow the progress in the [epic](https://gitlab.com/groups/gitlab-org/-/epics/2161).
If you need to replicate a new data type, reach out to the Geo
team to discuss the options. You can contact them in `#g_geo` on Slack
or mention `@geo-team` in the issue or merge request.

Geo provides an API to make it possible to easily replicate data types
across Geo nodes. This API is presented as a Ruby Domain-Specific
Language (DSL) and aims to make it possible to replicate data with
minimal effort of the engineer who created a data type.

## Nomenclature

Before digging into the API, developers need to know some Geo-specific
naming conventions:

- **Model**:
  A model is an Active Model, which is how it is known in the entire
  Rails codebase. It usually is tied to a database table. From Geo
  perspective, a model can have one or more resources.

- **Resource**:
  A resource is a piece of data that belongs to a model and is
  produced by a GitLab feature. It is persisted using a storage
  mechanism. By default, a resource is not a Geo replicable.

- **Data type**:
  Data type is how a resource is stored. Each resource should
  fit in one of the data types Geo supports:
  - Git repository
  - Blob
  - Database

  For more detail, see [Data types](../../administration/geo/replication/datatypes.md).

- **Geo Replicable**:
  A Replicable is a resource Geo wants to sync across Geo nodes. There
  is a limited set of supported data types of replicables. The effort
  required to implement replication of a resource that belongs to one
  of the known data types is minimal.

- **Geo Replicator**:
  A Geo Replicator is the object that knows how to replicate a
  replicable. It's responsible for:
  - Firing events (producer)
  - Consuming events (consumer)

  It's tied to the Geo Replicable data type. All replicators have a
  common interface that can be used to process (that is, produce and
  consume) events. It takes care of the communication between the
  primary node (where events are produced) and the secondary node
  (where events are consumed). The engineer who wants to incorporate
  Geo in their feature will use the API of replicators to make this
  happen.

- **Geo Domain-Specific Language**:
  The syntactic sugar that allows engineers to easily specify which
  resources should be replicated and how.

## Geo Domain-Specific Language

### The replicator

First of all, you need to write a replicator. The replicators live in
[`ee/app/replicators/geo`](https://gitlab.com/gitlab-org/gitlab/-/tree/master/ee/app/replicators/geo).
For each resource that needs to be replicated, there should be a
separate replicator specified, even if multiple resources are tied to
the same model.

For example, the following replicator replicates a package file:

```ruby
module Geo
  class PackageFileReplicator < Gitlab::Geo::Replicator
    # Include one of the strategies your resource needs
    include ::Geo::BlobReplicatorStrategy

    # Specify the CarrierWave uploader needed by the used strategy
    def carrierwave_uploader
      model_record.file
    end

    # Specify the model this replicator belongs to
    def self.model
      ::Packages::PackageFile
    end

    # The feature flag follows the format `geo_#{replicable_name}_replication`,
    # so here it would be `geo_package_file_replication`
    def self.replication_enabled_by_default?
      false
    end
  end
end
```

The class name should be unique. It also is tightly coupled to the
table name for the registry, so for this example the registry table
will be `package_file_registry`.

For the different data types Geo supports there are different
strategies to include. Pick one that fits your needs.

### Linking to a model

To tie this replicator to the model, you need to add the following to
the model code:

```ruby
class Packages::PackageFile < ApplicationRecord
  include ::Gitlab::Geo::ReplicableModel

  with_replicator Geo::PackageFileReplicator
end
```

### API

When this is set in place, it's easy to access the replicator through
the model:

```ruby
package_file = Packages::PackageFile.find(4) # just a random ID as example
replicator = package_file.replicator
```

Or get the model back from the replicator:

```ruby
replicator.model_record
=> <Packages::PackageFile id:4>
```

The replicator can be used to generate events, for example in
`ActiveRecord` hooks:

```ruby
  after_create_commit -> { replicator.publish_created_event }
```

#### Library

The framework behind all this is located in
[`ee/lib/gitlab/geo/`](https://gitlab.com/gitlab-org/gitlab/-/tree/master/ee/lib/gitlab/geo).

## Existing Replicator Strategies

Before writing a new kind of Replicator Strategy, check below to see if your
resource can already be handled by one of the existing strategies. Consult with
the Geo team if you are unsure.

### Blob Replicator Strategy

Models that use [CarrierWave's](https://github.com/carrierwaveuploader/carrierwave) `Uploader::Base` are supported by Geo with the `Geo::BlobReplicatorStrategy` module. For example, see how [Geo replication was implemented for Pipeline Artifacts](https://gitlab.com/gitlab-org/gitlab/-/issues/238464).

Each file is expected to have its own primary ID and model. Geo strongly recommends treating *every single file* as a first-class citizen, because in our experience this greatly simplifies tracking replication and verification state.

To implement Geo replication of a new blob-type Model, [open an issue with the provided issue template](https://gitlab.com/gitlab-org/gitlab/-/issues/new?issuable_template=Geo%3A%20Replicate%20a%20new%20blob%20type).

### Repository Replicator Strategy

Models that refer to any repository on the disk
can be easily supported by Geo with the `Geo::RepositoryReplicatorStrategy` module.

For example, to add support for files referenced by a `Gizmos` model with a
`gizmos` table, you would perform the following steps.

#### Replication

- [ ] Include `Gitlab::Geo::ReplicableModel` in the `Gizmo` class, and specify
   the Replicator class `with_replicator Geo::GizmoReplicator`.

   At this point the `Gizmo` class should look like this:

   ```ruby
   # frozen_string_literal: true

   class Gizmo < ApplicationRecord
     include ::Gitlab::Geo::ReplicableModel

     with_replicator Geo::GizmoReplicator

     # @param primary_key_in [Range, Gizmo] arg to pass to primary_key_in scope
     # @return [ActiveRecord::Relation<Gizmo>] everything that should be synced to this node, restricted by primary key
     def self.replicables_for_current_secondary(primary_key_in)
       # Should be implemented. The idea of the method is to restrict
       # the set of synced items depending on synchronization settings
     end

     # Geo checks this method in FrameworkRepositorySyncService to avoid
     # snapshotting repositories using object pools
     def pool_repository
       nil
     end
     ...
   end
   ```

   Pay some attention to method `pool_repository`. Not every repository type uses
   repository pooling. As Geo prefers to use repository snapshotting, it can lead to data loss.
   Make sure to overwrite `pool_repository` so it returns nil for repositories that do not
   have pools.

   If there is a common constraint for records to be available for replication,
   make sure to also overwrite the `available_replicables` scope.

- [ ] Create `ee/app/replicators/geo/gizmo_replicator.rb`. Implement the
   `#repository` method which should return a `<Repository>` instance,
   and implement the class method `.model` to return the `Gizmo` class:

   ```ruby
   # frozen_string_literal: true

   module Geo
     class GizmoReplicator < Gitlab::Geo::Replicator
       include ::Geo::RepositoryReplicatorStrategy

       def self.model
         ::Gizmo
       end

       def repository
         model_record.repository
       end

       def self.git_access_class
         ::Gitlab::GitAccessGizmo
       end

       # The feature flag follows the format `geo_#{replicable_name}_replication`,
       # so here it would be `geo_gizmo_replication`
       def self.replication_enabled_by_default?
         false
       end
     end
   end
   ```

- [ ] Generate the feature flag definition file by running the feature flag command
   and running through the steps:

   ```shell
   bin/feature-flag --ee geo_gizmo_replication --type development --group 'group::geo'
   ```

- [ ] Make sure Geo push events are created. Usually it needs some
   change in the `app/workers/post_receive.rb` file. Example:

   ```ruby
   def replicate_gizmo_changes(gizmo)
     if ::Gitlab::Geo.primary?
       gizmo.replicator.handle_after_update if gizmo
     end
   end
   ```

   See `app/workers/post_receive.rb` for more examples.

- [ ] Make sure the repository removal is also handled. You may need to add something
   like the following in the destroy service of the repository:

   ```ruby
   gizmo.replicator.handle_after_destroy if gizmo.repository
   ```

- [ ] Add this replicator class to the method `replicator_classes` in
   `ee/lib/gitlab/geo.rb`:

   ```ruby
   REPLICATOR_CLASSES = [
      ...
      ::Geo::PackageFileReplicator,
      ::Geo::GizmoReplicator
   ]
   end
   ```

- [ ] Create `ee/spec/replicators/geo/gizmo_replicator_spec.rb` and perform
   the necessary setup to define the `model_record` variable for the shared
   examples:

   ```ruby
   # frozen_string_literal: true

   require 'spec_helper'

   RSpec.describe Geo::GizmoReplicator do
     let(:model_record) { build(:gizmo) }

     include_examples 'a repository replicator'
   end
   ```

- [ ] Create the `gizmo_registry` table, with columns ordered according to [our guidelines](../ordering_table_columns.md) so Geo secondaries can track the sync and
   verification state of each Gizmo. This migration belongs in `ee/db/geo/migrate`:

   ```ruby
   # frozen_string_literal: true

   class CreateGizmoRegistry < ActiveRecord::Migration[6.0]
     include Gitlab::Database::MigrationHelpers

     disable_ddl_transaction!

     def up
       create_table :gizmo_registry, id: :bigserial, force: :cascade do |t|
         t.datetime_with_timezone :retry_at
         t.datetime_with_timezone :last_synced_at
         t.datetime_with_timezone :created_at, null: false
         t.bigint :gizmo_id, null: false
         t.integer :state, default: 0, null: false, limit: 2
         t.integer :retry_count, default: 0, limit: 2
         t.string :last_sync_failure, limit: 255
         t.boolean :force_to_redownload
         t.boolean :missing_on_primary

         t.index :gizmo_id, name: :index_gizmo_registry_on_gizmo_id, unique: true
         t.index :retry_at
         t.index :state
        end
      end

      def down
        drop_table :gizmo_registry
      end
   end
   ```

- [ ] Create `ee/app/models/geo/gizmo_registry.rb`:

   ```ruby
   # frozen_string_literal: true

   class Geo::GizmoRegistry < Geo::BaseRegistry
     include Geo::ReplicableRegistry

     MODEL_CLASS = ::Gizmo
     MODEL_FOREIGN_KEY = :gizmo_id

     belongs_to :gizmo, class_name: 'Gizmo'
   end
   ```

- [ ] Update `REGISTRY_CLASSES` in `ee/app/workers/geo/secondary/registry_consistency_worker.rb`.
- [ ] Add `gizmo_registry` to `ActiveSupport::Inflector.inflections` in `config/initializers_before_autoloader/000_inflections.rb`.
- [ ] Create `ee/spec/factories/geo/gizmo_registry.rb`:

   ```ruby
   # frozen_string_literal: true

   FactoryBot.define do
     factory :geo_gizmo_registry, class: 'Geo::GizmoRegistry' do
       gizmo
       state { Geo::GizmoRegistry.state_value(:pending) }

       trait :synced do
         state { Geo::GizmoRegistry.state_value(:synced) }
         last_synced_at { 5.days.ago }
       end

       trait :failed do
         state { Geo::GizmoRegistry.state_value(:failed) }
         last_synced_at { 1.day.ago }
         retry_count { 2 }
         last_sync_failure { 'Random error' }
       end

       trait :started do
         state { Geo::GizmoRegistry.state_value(:started) }
         last_synced_at { 1.day.ago }
         retry_count { 0 }
       end
     end
   end
   ```

- [ ] Create `ee/spec/models/geo/gizmo_registry_spec.rb`:

   ```ruby
   # frozen_string_literal: true

   require 'spec_helper'

   RSpec.describe Geo::GizmoRegistry, :geo, type: :model do
     let_it_be(:registry) { create(:geo_gizmo_registry) }

     specify 'factory is valid' do
       expect(registry).to be_valid
     end

     include_examples 'a Geo framework registry'
   end
   ```

- [ ] Make sure the newly added repository type can be accessed by a secondary.
   You may need to make some changes to one of the Git access classes.

   Gizmos should now be replicated by Geo.

#### Metrics

You need to make the same changes as for Blob Replicator Strategy.
You need to make the same changes for the [metrics as in the Blob Replicator Strategy](#metrics).

#### GraphQL API

You need to make the same changes for the GraphQL API [as in the Blob Replicator Strategy](#graphql-api).

#### Releasing the feature

You need to make the same changes for [releasing the feature as in the Blob Replicator Strategy](#releasing-the-feature).

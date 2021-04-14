<!--

Find and replace the following (plurals are listed separately in case your Model uses a non-standard pluralization):

- `CoolWidgets`
- `CoolWidget`
- `Cool Widgets`
- `Cool Widget`
- `cool_widgets`
- `cool_widget`

-->

## Replicate Cool Widgets

This issue is for implementing Geo replication and verification of Cool Widgets.

For more background, see [Blob Replicator Strategy](https://docs.gitlab.com/ee/development/geo/framework.html#blob-replicator-strategy).

There are three main sections below:

1. Modify database schemas to prepare to add Geo support for Cool Widgets
1. Implement Geo support of Cool Widgets behind a feature flag
1. Release Geo support of Cool Widgets

### Modify database schemas to prepare to add Geo support for Cool Widgets

You might do this section in its own merge request, but it is not required.

#### Add the registry table to track replication and verification state

Geo secondary sites have a [Geo tracking database](https://docs.gitlab.com/ee/administration/geo/#geo-tracking-database) independent of the main database which is used to track the replication and verification state of all replicables. Every Model has a corresponding "registry" table in the Geo tracking database.

- [ ] Create the migration file in `ee/db/geo/migrate`:

  ```shell
  bin/rails generate geo_migration CreateWidgetRegistry
  ```

- [ ] Replace the contents of the migration file with:

  ```ruby
  # frozen_string_literal: true

  class CreateWidgetRegistry < ActiveRecord::Migration[6.0]
    include Gitlab::Database::MigrationHelpers

    disable_ddl_transaction!

    def up
      unless table_exists?(:widget_registry)
        ActiveRecord::Base.transaction do
          create_table :widget_registry, id: :bigserial, force: :cascade do |t|
            t.bigint :widget_id, null: false
            t.datetime_with_timezone :created_at, null: false
            t.datetime_with_timezone :last_synced_at
            t.datetime_with_timezone :retry_at
            t.datetime_with_timezone :verified_at
            t.datetime_with_timezone :verification_started_at
            t.datetime_with_timezone :verification_retry_at
            t.integer :state, default: 0, null: false, limit: 2
            t.integer :verification_state, default: 0, null: false, limit: 2
            t.integer :retry_count, default: 0, limit: 2
            t.integer :verification_retry_count, default: 0, limit: 2
            t.boolean :checksum_mismatch, default: false, null: false
            t.binary :verification_checksum
            t.binary :verification_checksum_mismatched
            t.string :verification_failure, limit: 255 # rubocop:disable Migration/PreventStrings see https://gitlab.com/gitlab-org/gitlab/-/issues/323806
            t.string :last_sync_failure, limit: 255 # rubocop:disable Migration/PreventStrings see https://gitlab.com/gitlab-org/gitlab/-/issues/323806

            t.index :widget_id, name: :index_widget_registry_on_widget_id, unique: true
            t.index :retry_at
            t.index :state
            # To optimize performance of WidgetRegistry.verification_failed_batch
            t.index :verification_retry_at, name:  :widget_registry_failed_verification, order: "NULLS FIRST",  where: "((state = 2) AND (verification_state = 3))"
            # To optimize performance of WidgetRegistry.needs_verification_count
            t.index :verification_state, name:  :widget_registry_needs_verification, where: "((state = 2)  AND (verification_state = ANY (ARRAY[0, 3])))"
            # To optimize performance of WidgetRegistry.verification_pending_batch
            t.index :verified_at, name: :widget_registry_pending_verification, order: "NULLS FIRST", where: "((state = 2) AND (verification_state = 0))"
          end
        end
      end
    end

    def down
      drop_table :widget_registry
    end
  end
  ```

- [ ] If deviating from the above example, then be sure to order columns according to [our guidelines](https://docs.gitlab.com/ee/development/ordering_table_columns.html).
- [ ] Run Geo tracking database migrations:

  ```shell
  bin/rake geo:db:migrate
  ```

### Add verification state fields on the Geo primary site

The Geo primary site needs to checksum every replicable in order for secondaries to verify their own checksums. To do this, Geo requires fields on the Model. There are two ways to add the necessary verification state fields. If the table is large and wide, then it may be a good idea to add verification state fields to a separate table (Option 2). Consult a database expert if needed.

#### Add verification state fields to the model table (Option 1)

- [ ] Create the migration file in `db/migrate`:

  ```shell
  bin/rails generate migration AddVerificationStateToWidgets
  ```

- [ ] Replace the contents of the migration file with:

  ```ruby
  # frozen_string_literal: true

  class AddVerificationStateToWidgets < ActiveRecord::Migration[6.0]
    def change
      change_table(:widgets) do |t|
        t.integer :verification_state, default: 0, limit: 2, null: false
        t.column :verification_started_at, :datetime_with_timezone
        t.integer :verification_retry_count, limit: 2
        t.column :verification_retry_at, :datetime_with_timezone
        t.column :verified_at, :datetime_with_timezone
        t.binary :verification_checksum, using: 'verification_checksum::bytea'

        t.text :verification_failure # rubocop:disable Migration/AddLimitToTextColumns
      end
    end
  end
  ```

- [ ] If deviating from the above example, then be sure to order columns according to [our guidelines](https://docs.gitlab.com/ee/development/ordering_table_columns.html).
- [ ] If `cool_widgets` is a high-traffic table, follow [the database docs to use `with_lock_retries`](https://docs.gitlab.com/ee/development/migration_style_guide.html#when-to-use-the-helper-method)
- [ ] Adding a `text` column also [requires](../database/strings_and_the_text_data_type.md#add-a-text-column-to-an-existing-table) setting a limit. Create the migration file in `db/migrate`:

  ```shell
  bin/rails generate migration AddVerificationFailureLimitToWidgets
  ```

- [ ] Replace the contents of the migration file with:

  ```ruby
  # frozen_string_literal: true

  class AddVerificationFailureLimitToWidgets < ActiveRecord::Migration[6.0]
    include Gitlab::Database::MigrationHelpers

    disable_ddl_transaction!

    CONSTRAINT_NAME = 'widget_verification_failure_text_limit'

    def up
      add_text_limit :widget, :verification_failure, 255, constraint_name: CONSTRAINT_NAME
    end

    def down
      remove_check_constraint(:widget, CONSTRAINT_NAME)
    end
  end
  ```

- [ ] Add indexes on verification fields to ensure verification can be performed efficiently. Some or all of these indexes can be omitted if the table is guaranteed to be small. Ask a database expert if you are considering omitting indexes. Create the migration file in `db/migrate`:

  ```shell
  bin/rails generate migration AddVerificationIndexesToWidgets
  ```

- [ ] Replace the contents of the migration file with:

  ```ruby
  # frozen_string_literal: true

  class AddVerificationIndexesToWidgets < ActiveRecord::Migration[6.0]
    include Gitlab::Database::MigrationHelpers

    VERIFICATION_STATE_INDEX_NAME = "index_widgets_on_verification_state"
    PENDING_VERIFICATION_INDEX_NAME = "index_widgets_pending_verification"
    FAILED_VERIFICATION_INDEX_NAME = "index_widgets_failed_verification"
    NEEDS_VERIFICATION_INDEX_NAME = "index_widgets_needs_verification"

    disable_ddl_transaction!

    def up
      add_concurrent_index :widgets, :verification_state, name: VERIFICATION_STATE_INDEX_NAME
      add_concurrent_index :widgets, :verified_at, where: "(verification_state = 0)", order: { verified_at: 'ASC NULLS FIRST' }, name: PENDING_VERIFICATION_INDEX_NAME
      add_concurrent_index :widgets, :verification_retry_at, where: "(verification_state = 3)", order: { verification_retry_at: 'ASC NULLS FIRST' }, name: FAILED_VERIFICATION_INDEX_NAME
      add_concurrent_index :widgets, :verification_state, where: "(verification_state = 0 OR verification_state = 3)", name: NEEDS_VERIFICATION_INDEX_NAME
    end

    def down
      remove_concurrent_index_by_name :widgets, VERIFICATION_STATE_INDEX_NAME
      remove_concurrent_index_by_name :widgets, PENDING_VERIFICATION_INDEX_NAME
      remove_concurrent_index_by_name :widgets, FAILED_VERIFICATION_INDEX_NAME
      remove_concurrent_index_by_name :widgets, NEEDS_VERIFICATION_INDEX_NAME
    end
  end
  ```

- [ ] Run database migrations:

  ```shell
  bin/rake db:migrate
  ```

#### Add verification state fields to a separate table (Option 2)

- [ ] Create the migration file in `db/migrate`:

  ```shell
  bin/rails generate migration CreateWidgetStates
  ```

- [ ] Replace the contents of the migration file with:

  ```ruby
  # frozen_string_literal: true

  class CreateWidgetStates < ActiveRecord::Migration[6.0]
    include Gitlab::Database::MigrationHelpers

    VERIFICATION_STATE_INDEX_NAME = "index_widget_states_on_verification_state"
    PENDING_VERIFICATION_INDEX_NAME = "index_widget_states_pending_verification"
    FAILED_VERIFICATION_INDEX_NAME = "index_widget_states_failed_verification"
    NEEDS_VERIFICATION_INDEX_NAME = "index_widget_states_needs_verification"

    disable_ddl_transaction!

    def up
      unless table_exists?(:widget_states)
        with_lock_retries do
          create_table :widget_states, id: false do |t|
            t.references :widget, primary_key: true, null: false, foreign_key: { on_delete: :cascade }
            t.integer :verification_state, default: 0, limit: 2, null: false
            t.column :verification_started_at, :datetime_with_timezone
            t.datetime_with_timezone :verification_retry_at
            t.datetime_with_timezone :verified_at
            t.integer :verification_retry_count, limit: 2
            t.binary :verification_checksum, using: 'verification_checksum::bytea'
            t.text :verification_failure

            t.index :verification_state, name: VERIFICATION_STATE_INDEX_NAME
            t.index :verified_at, where: "(verification_state = 0)", order: { verified_at: 'ASC NULLS FIRST' }, name: PENDING_VERIFICATION_INDEX_NAME
            t.index :verification_retry_at, where: "(verification_state = 3)", order: { verification_retry_at: 'ASC NULLS FIRST' }, name: FAILED_VERIFICATION_INDEX_NAME
            t.index :verification_state, where: "(verification_state = 0 OR verification_state = 3)", name: NEEDS_VERIFICATION_INDEX_NAME
          end
        end
      end

      add_text_limit :widget_states, :verification_failure, 255
    end

    def down
      drop_table :widget_states
    end
  end
  ```

- [ ] If deviating from the above example, then be sure to order columns according to [our guidelines](https://docs.gitlab.com/ee/development/ordering_table_columns.html).
- [ ] Run database migrations:

  ```shell
  bin/rake db:migrate
  ```

That's all of the required database changes.

### Implement Geo support of Cool Widgets behind a feature flag

#### Step 1. Implement replication and verification

- [ ] Include `Gitlab::Geo::ReplicableModel` in the `Widget` class, and specify
  the Replicator class `with_replicator Geo::WidgetReplicator`.

  At this point the `Widget` class should look like this:

  ```ruby
  # frozen_string_literal: true

  class Widget < ApplicationRecord
    include ::Gitlab::Geo::ReplicableModel
    include ::Gitlab::Geo::VerificationState

    with_replicator Geo::WidgetReplicator

    mount_uploader :file, WidgetUploader

    # Override the `all` default if not all records can be replicated.
    # scope :available_replicables, -> { all }

    # @param primary_key_in [Range, Widget] arg to pass to primary_key_in scope
    # @return [ActiveRecord::Relation<Widget>] everything that should be synced to this node, restricted by primary key
    def self.replicables_for_current_secondary(primary_key_in)
      # Should be implemented. The idea of the method is to restrict the set of
      # synced items depending on synchronization settings. Search the codebase
      # for examples.
    end
    ...
  end
  ```

- [ ] Implement `Widget.replicables_for_current_secondary` above.
- [ ] If you are using a separate table `widget_states` to track verification state on the Geo primary site, then:
  - [ ] Do not include `::Gitlab::Geo::VerificationState` on the `Widget` class.
  - [ ] Add the following lines to the `widget_state.rb` model:

    ```ruby
    class WidgetState < ApplicationRecord
      ...
      self.primary_key = :widget_id

      include ::Gitlab::Geo::VerificationState

      belongs_to :widget, inverse_of: :widget_state
      ...
    end
    ```

  - [ ] Add the following lines to the `widget` model:

    ```ruby
    class Widget < ApplicationRecord
      ...
      has_one :widget_state, inverse_of: :widget

      delegate :verification_retry_at, :verification_retry_at=,
              :verified_at, :verified_at=,
              :verification_checksum, :verification_checksum=,
              :verification_failure, :verification_failure=,
              :verification_retry_count, :verification_retry_count=,
              to: :widget_state
      ...
    end
    ```

- [ ] Create `ee/app/replicators/geo/widget_replicator.rb`. Implement the
  `#carrierwave_uploader` method which should return a `CarrierWave::Uploader`,
  and implement the class method `.model` to return the `Widget` class:

  ```ruby
  # frozen_string_literal: true

  module Geo
    class WidgetReplicator < Gitlab::Geo::Replicator
      include ::Geo::BlobReplicatorStrategy

      def self.model
        ::Widget
      end

      def carrierwave_uploader
        model_record.file
      end

      # The feature flag follows the format `geo_#{replicable_name}_replication`,
      # so here it would be `geo_widget_replication`
      def self.replication_enabled_by_default?
        false
      end
    end
  end
  ```

- [ ] Generate the feature flag definition file by running the feature flag command and running through the steps:

  ```shell
  bin/feature-flag --ee geo_widget_replication --type development --group 'group::geo'
  ```

- [ ] Add this replicator class to the method `replicator_classes` in
  `ee/lib/gitlab/geo.rb`:

  ```ruby
  REPLICATOR_CLASSES = [
    ::Geo::PackageFileReplicator,
    ::Geo::WidgetReplicator
  ]
  end
  ```

- [ ] Create `ee/spec/replicators/geo/widget_replicator_spec.rb` and perform
  the necessary setup to define the `model_record` variable for the shared
  examples:

  ```ruby
  # frozen_string_literal: true

  require 'spec_helper'

  RSpec.describe Geo::WidgetReplicator do
    let(:model_record) { build(:widget) }

    it_behaves_like 'a blob replicator'
  end
  ```

- [ ] Create `ee/app/models/geo/widget_registry.rb`:

  ```ruby
  # frozen_string_literal: true

  class Geo::WidgetRegistry < Geo::BaseRegistry
    include ::Geo::ReplicableRegistry
    include ::Geo::VerifiableRegistry

    MODEL_CLASS = ::Widget
    MODEL_FOREIGN_KEY = :widget_id

    belongs_to :widget, class_name: 'Widget'
  end
  ```

- [ ] Update `REGISTRY_CLASSES` in `ee/app/workers/geo/secondary/registry_consistency_worker.rb`.
- [ ] Add `widget_registry` to `ActiveSupport::Inflector.inflections` in `config/initializers_before_autoloader/000_inflections.rb`.
- [ ] Create `ee/spec/factories/geo/widget_registry.rb`:

  ```ruby
  # frozen_string_literal: true

  FactoryBot.define do
    factory :geo_widget_registry, class: 'Geo::WidgetRegistry' do
      widget
      state { Geo::WidgetRegistry.state_value(:pending) }

      trait :synced do
        state { Geo::WidgetRegistry.state_value(:synced) }
        last_synced_at { 5.days.ago }
      end

      trait :failed do
        state { Geo::WidgetRegistry.state_value(:failed) }
        last_synced_at { 1.day.ago }
        retry_count { 2 }
        last_sync_failure { 'Random error' }
      end

      trait :started do
        state { Geo::WidgetRegistry.state_value(:started) }
        last_synced_at { 1.day.ago }
        retry_count { 0 }
      end
    end
  end
  ```

- [ ] Create `ee/spec/models/geo/widget_registry_spec.rb`:

  ```ruby
  # frozen_string_literal: true

  require 'spec_helper'

  RSpec.describe Geo::WidgetRegistry, :geo, type: :model do
    let_it_be(:registry) { create(:geo_widget_registry) }

    specify 'factory is valid' do
      expect(registry).to be_valid
    end

    include_examples 'a Geo framework registry'
    include_examples 'a Geo verifiable registry'
  end
  ```

#### Step 2. Implement metrics gathering

Metrics are gathered by `Geo::MetricsUpdateWorker`, persisted in `GeoNodeStatus` for display in the UI, and sent to Prometheus:

- [ ] Add the following fields to Geo Node Status example responses in `doc/api/geo_nodes.md`:
  - `widgets_count`
  - `widgets_checksum_total_count`
  - `widgets_checksummed_count`
  - `widgets_checksum_failed_count`
  - `widgets_synced_count`
  - `widgets_failed_count`
  - `widgets_registry_count`
  - `widgets_verification_total_count`
  - `widgets_verified_count`
  - `widgets_verification_failed_count`
  - `widgets_synced_in_percentage`
  - `widgets_verified_in_percentage`
- [ ] Add the same fields to `GET /geo_nodes/status` example response in
  `ee/spec/fixtures/api/schemas/public_api/v4/geo_node_status.json`.
- [ ] Add the following fields to the `Sidekiq metrics` table in `doc/administration/monitoring/prometheus/gitlab_metrics.md`:
  - `geo_widgets`
  - `geo_widgets_checksum_total`
  - `geo_widgets_checksummed`
  - `geo_widgets_checksum_failed`
  - `geo_widgets_synced`
  - `geo_widgets_failed`
  - `geo_widgets_registry`
  - `geo_widgets_verification_total`
  - `geo_widgets_verified`
  - `geo_widgets_verification_failed`
- [ ] Add the following to the parameterized table in the `context 'Replicator stats' do` block in `ee/spec/models/geo_node_status_spec.rb`:

  ```ruby
  Geo::WidgetReplicator | :widget | :geo_widget_registry
  ```

- [ ] Add the following to `spec/factories/widgets.rb`:

  ```ruby
  trait(:verification_succeeded) do
    with_file
    verification_checksum { 'abc' }
    verification_state { Widget.verification_state_value(:verification_succeeded) }
  end

  trait(:verification_failed) do
    with_file
    verification_failure { 'Could not calculate the checksum' }
    verification_state { Widget.verification_state_value(:verification_failed) }
  end
  ```

- [ ] Make sure the factory also allows setting a `project` attribute. If the model
  does not have a direct relation to a project, you can use a `transient`
  attribute. Check out `spec/factories/merge_request_diffs.rb` for an example.

Widget replication and verification metrics should now be available in the API,
the `Admin > Geo > Nodes` view, and Prometheus.

#### Step 3. Implement the GraphQL API

The GraphQL API is used by `Admin > Geo > Replication Details` views, and is
directly queryable by admins.

- [ ] Add a new field to `GeoNodeType` in `ee/app/graphql/types/geo/geo_node_type.rb`:

  ```ruby
  field :widget_registries, ::Types::Geo::WidgetRegistryType.connection_type,
        null: true,
        resolver: ::Resolvers::Geo::WidgetRegistriesResolver,
        description: 'Find widget registries on this Geo node',
        feature_flag: :geo_widget_replication
  ```

- [ ] Add the new `widget_registries` field name to the `expected_fields` array in `ee/spec/graphql/types/geo/geo_node_type_spec.rb`.
- [ ] Create `ee/app/graphql/resolvers/geo/widget_registries_resolver.rb`:

  ```ruby
  # frozen_string_literal: true

  module Resolvers
    module Geo
      class WidgetRegistriesResolver < BaseResolver
        include RegistriesResolver
      end
    end
  end
  ```

- [ ] Create `ee/spec/graphql/resolvers/geo/widget_registries_resolver_spec.rb`:

  ```ruby
  # frozen_string_literal: true

  require 'spec_helper'

  RSpec.describe Resolvers::Geo::WidgetRegistriesResolver do
    it_behaves_like 'a Geo registries resolver', :geo_widget_registry
  end
  ```

- [ ] Create `ee/app/finders/geo/widget_registry_finder.rb`:

  ```ruby
  # frozen_string_literal: true

  module Geo
    class WidgetRegistryFinder
      include FrameworkRegistryFinder
    end
  end
  ```

- [ ] Create `ee/spec/finders/geo/widget_registry_finder_spec.rb`:

  ```ruby
  # frozen_string_literal: true

  require 'spec_helper'

  RSpec.describe Geo::WidgetRegistryFinder do
    it_behaves_like 'a framework registry finder', :geo_widget_registry
  end
  ```

- [ ] Create `ee/app/graphql/types/geo/widget_registry_type.rb`:

  ```ruby
  # frozen_string_literal: true

  module Types
    module Geo
      # rubocop:disable Graphql/AuthorizeTypes because it is included
      class WidgetRegistryType < BaseObject
        include ::Types::Geo::RegistryType

        graphql_name 'WidgetRegistry'
        description 'Represents the Geo sync and verification state of a widget'

        field :widget_id, GraphQL::ID_TYPE, null: false, description: 'ID of the Widget'
      end
    end
  end
  ```

- [ ] Create `ee/spec/graphql/types/geo/widget_registry_type_spec.rb`:

  ```ruby
  # frozen_string_literal: true

  require 'spec_helper'

  RSpec.describe GitlabSchema.types['WidgetRegistry'] do
    it_behaves_like 'a Geo registry type'

    it 'has the expected fields (other than those included in RegistryType)' do
      expected_fields = %i[widget_id]

      expect(described_class).to have_graphql_fields(*expected_fields).at_least
    end
  end
  ```

- [ ] Add integration tests for providing Widget registry data to the frontend via the GraphQL API, by duplicating and modifying the following shared examples in `ee/spec/requests/api/graphql/geo/registries_spec.rb`:

  ```ruby
  it_behaves_like 'gets registries for', {
    field_name: 'widgetRegistries',
    registry_class_name: 'WidgetRegistry',
    registry_factory: :geo_widget_registry,
    registry_foreign_key_field_name: 'widgetId'
  }
  ```

- [ ] Update the GraphQL reference documentation:

  ```shell
  bundle exec rake gitlab:graphql:compile_docs
  ```

Individual widget synchronization and verification data should now be available
via the GraphQL API.

### Release Geo support of Cool Widgets

- [ ] In `ee/config/feature_flags/development/geo_widget_replication.yml`, set `default_enabled: true`

- [ ] In `ee/app/replicators/geo/widget_replicator.rb`, delete the `self.replication_enabled_by_default?` method:

  ```ruby
  module Geo
    class WidgetReplicator < Gitlab::Geo::Replicator
      ...

      # REMOVE THIS METHOD
      def self.replication_enabled_by_default?
        false
      end
      # REMOVE THIS METHOD

      ...
    end
  end
  ```

- [ ] In `ee/app/graphql/types/geo/geo_node_type.rb`, remove the `feature_flag` option for the released type:

  ```ruby
  field :widget_registries, ::Types::Geo::WidgetRegistryType.connection_type,
        null: true,
        resolver: ::Resolvers::Geo::WidgetRegistriesResolver,
        description: 'Find widget registries on this Geo node',
        feature_flag: :geo_widget_replication # REMOVE THIS LINE
  ```

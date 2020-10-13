<script>
import { GlLink, GlSprintf, GlModalDirective, GlButton, GlIcon } from '@gitlab/ui';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import ProjectsTable from './projects_table.vue';
import UsageGraph from './usage_graph.vue';
import UsageStatistics from './usage_statistics.vue';
import StorageInlineAlert from './storage_inline_alert.vue';
import query from '../queries/storage.query.graphql';
import TemporaryStorageIncreaseModal from './temporary_storage_increase_modal.vue';
import { numberToHumanSize } from '~/lib/utils/number_utils';
import { parseBoolean } from '~/lib/utils/common_utils';

export default {
  name: 'StorageCounterApp',
  components: {
    ProjectsTable,
    GlLink,
    GlButton,
    GlSprintf,
    GlIcon,
    StorageInlineAlert,
    UsageGraph,
    UsageStatistics,
    TemporaryStorageIncreaseModal,
  },
  directives: {
    GlModalDirective,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    namespacePath: {
      type: String,
      required: true,
    },
    helpPagePath: {
      type: String,
      required: true,
    },
    purchaseStorageUrl: {
      type: String,
      required: false,
      default: null,
    },
    isTemporaryStorageIncreaseVisible: {
      type: String,
      required: false,
      default: 'false',
    },
  },
  apollo: {
    namespace: {
      query,
      variables() {
        return {
          fullPath: this.namespacePath,
          withExcessStorageData: this.isAdditionalStorageFlagEnabled,
        };
      },
      /**
       * `rootStorageStatistics` will be sent as null until an
       * event happens to trigger the storage count.
       * For that reason we have to verify if `storageSize` is sent or
       * if we should render N/A
       */
      update: data => ({
        projects: data.namespace.projects.edges.map(({ node }) => node),
        totalUsage:
          data.namespace.rootStorageStatistics && data.namespace.rootStorageStatistics.storageSize
            ? numberToHumanSize(data.namespace.rootStorageStatistics.storageSize)
            : 'N/A',
        rootStorageStatistics: data.namespace.rootStorageStatistics,
        limit: data.namespace.storageSizeLimit,
        containsLockedProjects: data.namespace.containsLockedProjects,
        repositorySizeExcessProjectCount: data.namespace.repositorySizeExcessProjectCount,
        totalRepositorySizeExcess: data.namespace.totalRepositorySizeExcess,
        totalRepositorySize: data.namespace.totalRepositorySize,
        additionalPurchasedStorageSize: data.namespace.additionalPurchasedStorageSize,
        actualRepositorySizeLimit: data.namespace.actualRepositorySizeLimit,
      }),
    },
  },
  data() {
    return {
      namespace: {},
    };
  },
  computed: {
    namespaceProjects() {
      return this.namespace?.projects ?? [];
    },
    isStorageIncreaseModalVisible() {
      return parseBoolean(this.isTemporaryStorageIncreaseVisible);
    },
    isAdditionalStorageFlagEnabled() {
      return this.glFeatures.additionalRepoStorageByNamespace;
    },
    shouldShowStorageInlineAlert() {
      return this.isAdditionalStorageFlagEnabled && !this.$apollo.queries.namespace.loading;
    },
  },
  methods: {
    formatSize(size) {
      return numberToHumanSize(size);
    },
  },
  modalId: 'temporary-increase-storage-modal',
};
</script>
<template>
  <div>
    <storage-inline-alert
      v-if="shouldShowStorageInlineAlert"
      :contains-locked-projects="namespace.containsLockedProjects"
      :repository-size-excess-project-count="namespace.repositorySizeExcessProjectCount"
      :total-repository-size-excess="namespace.totalRepositorySizeExcess"
      :total-repository-size="namespace.totalRepositorySize"
      :additional-purchased-storage-size="namespace.additionalPurchasedStorageSize"
      :actual-repository-size-limit="namespace.actualRepositorySizeLimit"
    />
    <div v-if="isAdditionalStorageFlagEnabled && namespace.rootStorageStatistics">
      <usage-statistics :root-storage-statistics="namespace.rootStorageStatistics" />
    </div>
    <div v-else class="gl-py-4 gl-px-2 gl-m-0">
      <div class="gl-display-flex gl-align-items-center">
        <div class="gl-w-half">
          <gl-sprintf :message="s__('UsageQuota|You used: %{usage} %{limit}')">
            <template #usage>
              <span class="gl-font-weight-bold" data-testid="total-usage">
                {{ namespace.totalUsage }}
              </span>
            </template>
            <template #limit>
              <gl-sprintf
                v-if="namespace.limit"
                :message="s__('UsageQuota|out of %{formattedLimit} of your namespace storage')"
              >
                <template #formattedLimit>
                  <span class="gl-font-weight-bold">{{ formatSize(namespace.limit) }}</span>
                </template>
              </gl-sprintf>
            </template>
          </gl-sprintf>
          <gl-link
            :href="helpPagePath"
            target="_blank"
            :aria-label="s__('UsageQuota|Usage quotas help link')"
          >
            <gl-icon name="question" :size="12" />
          </gl-link>
        </div>
        <div class="gl-w-half gl-text-right">
          <gl-button
            v-if="isStorageIncreaseModalVisible"
            v-gl-modal-directive="$options.modalId"
            category="secondary"
            variant="success"
            data-testid="temporary-storage-increase-button"
            >{{ s__('UsageQuota|Increase storage temporarily') }}</gl-button
          >
          <gl-link
            v-if="purchaseStorageUrl"
            :href="purchaseStorageUrl"
            class="btn btn-success gl-ml-2"
            target="_blank"
            data-testid="purchase-storage-link"
            >{{ s__('UsageQuota|Purchase more storage') }}</gl-link
          >
        </div>
      </div>
      <div v-if="namespace.rootStorageStatistics" class="gl-w-full">
        <usage-graph
          :root-storage-statistics="namespace.rootStorageStatistics"
          :limit="namespace.limit"
        />
      </div>
    </div>
    <projects-table :projects="namespaceProjects" />
    <temporary-storage-increase-modal
      v-if="isStorageIncreaseModalVisible"
      :limit="formatSize(namespace.limit)"
      :modal-id="$options.modalId"
    />
  </div>
</template>

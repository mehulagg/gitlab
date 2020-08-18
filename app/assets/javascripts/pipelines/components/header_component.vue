<script>
import { GlLoadingIcon, GlModal, GlModalDirective, GlButton } from '@gitlab/ui';
import Flash from '~/flash';
import { __ } from '~/locale';
import axios from '~/lib/utils/axios_utils';
import getPipelineQuery from '../graphql/queries/get_pipeline_header_data.query.graphql';
import { PIPELINE_CANCELED, PIPELINE_FAILED, PIPELINE_RUNNING } from '../constants';
import ciHeader from '~/vue_shared/components/header_ci_component.vue';
import { setUrlFragment, redirectTo } from '~/lib/utils/url_utility';

const DELETE_MODAL_ID = 'pipeline-delete-modal';

export default {
  name: 'PipelineHeaderSection',
  components: {
    ciHeader,
    GlButton,
    GlLoadingIcon,
    GlModal,
  },
  directives: {
    GlModal: GlModalDirective,
  },
  inject: {
    // Receive `cancel`, `delete`, `fullProject` and `retry`
    paths: {
      default: {},
    },
    pipelineId: {
      default: '',
    },
    pipelineIid: {
      default: '',
    },
  },
  apollo: {
    pipeline: {
      query: getPipelineQuery,
      variables() {
        return {
          fullPath: this.paths.fullProject,
          iid: this.pipelineIid,
        };
      },
      update: data => data.project.pipeline,
      pollInterval: 10000,
      watchLoading(isLoading) {
        if (!isLoading) {
          // To ensure apollo has updated the cache,
          // we only remove the loading state in sync with GraphQL
          this.isCanceling = false;
          this.isRetrying = false;
        }
      },
    },
  },
  data() {
    return {
      pipeline: {},
      isCanceling: false,
      isRetrying: false,
      isDeleting: false,
    };
  },
  computed: {
    deleteModalConfirmationText() {
      return __(
        'Are you sure you want to delete this pipeline? Doing so will expire all pipeline caches and delete all related objects, such as builds, logs, artifacts, and triggers. This action cannot be undone.',
      );
    },
    hasPipelineData() {
      return Object.keys(this.pipeline).length > 0;
    },
    isLoadingInitialQuery() {
      return this.$apollo.queries.pipeline.loading && !this.hasPipelineData;
    },
    canCancelPipeline() {
      return this.paths.cancel && this.pipeline.status === PIPELINE_RUNNING;
    },
    canRetryPipeline() {
      return (
        this.paths.retry &&
        (this.pipeline.status === PIPELINE_CANCELED || this.pipeline.status === PIPELINE_FAILED)
      );
    },
    status() {
      return this?.pipeline.status;
    },
    shouldRenderContent() {
      return !this.isLoadingInitialQuery && this.hasPipelineData;
    },
  },
  methods: {
    async postAction(path) {
      try {
        await axios.post(path);
        this.$apollo.queries.pipeline.refetch();
      } catch {
        Flash(__('An error occurred while making the request.'));
      }
    },
    async cancelPipeline() {
      this.isCanceling = true;
      await this.postAction(this.paths.cancel);
    },
    async retryPipeline() {
      this.isRetrying = true;
      await this.postAction(this.paths.retry);
    },
    async deletePipeline() {
      this.isDeleting = true;
      this.$apollo.queries.pipeline.stopPolling();

      try {
        const { request } = await axios.delete(this.paths.delete);
        redirectTo(setUrlFragment(request.responseURL, 'delete_success'));
      } catch {
        this.$apollo.queries.pipeline.startPolling();
        Flash(__('An error occurred while deleting the pipeline.'));
        this.isDeleting = false;
      }
    },
  },
  DELETE_MODAL_ID,
};
</script>
<template>
  <div class="pipeline-header-container">
    <ci-header
      v-if="shouldRenderContent"
      :status="pipeline.detailedStatus"
      :time="pipeline.createdAt"
      :user="pipeline.user"
      :item-id="Number(pipelineId)"
      item-name="Pipeline"
    >
      <gl-button
        v-if="canRetryPipeline"
        :loading="isRetrying"
        :disabled="isRetrying"
        category="secondary"
        variant="info"
        data-testid="retryPipeline"
        class="js-retry-button"
        @click="retryPipeline()"
      >
        {{ __('Retry') }}
      </gl-button>

      <gl-button
        v-if="canCancelPipeline"
        :loading="isCanceling"
        :disabled="isCanceling"
        variant="danger"
        data-testid="cancelPipeline"
        @click="cancelPipeline()"
      >
        {{ __('Cancel running') }}
      </gl-button>

      <gl-button
        v-if="paths.delete"
        v-gl-modal="$options.DELETE_MODAL_ID"
        :loading="isDeleting"
        :disabled="isDeleting"
        class="gl-ml-3"
        variant="danger"
        category="secondary"
        data-testid="deletePipeline"
      >
        {{ __('Delete') }}
      </gl-button>
    </ci-header>
    <gl-loading-icon v-if="isLoadingInitialQuery" size="lg" class="gl-mt-3 gl-mb-3" />

    <gl-modal
      :modal-id="$options.DELETE_MODAL_ID"
      :title="__('Delete pipeline')"
      :ok-title="__('Delete pipeline')"
      ok-variant="danger"
      @ok="deletePipeline()"
    >
      <p>
        {{ deleteModalConfirmationText }}
      </p>
    </gl-modal>
  </div>
</template>

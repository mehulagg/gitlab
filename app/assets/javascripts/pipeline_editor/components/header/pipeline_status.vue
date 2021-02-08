<script>
import { GlAlert, GlLink, GlLoadingIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import CiIcon from '~/vue_shared/components/ci_icon.vue';
import getCommitSha from '~/pipeline_editor/graphql/queries/client/commit_sha.graphql';
import getPipelineQuery from '~/pipeline_editor/graphql/queries/client/pipeline.graphql';

const POLL_INTERVAL = 10000;
const FETCH_ERROR_MESSAGE = 'We are currently unable to fetch data for the pipeline header.';

export default {
  components: {
    CiIcon,
    GlLink,
    GlAlert,
    GlLoadingIcon,
  },
  inject: ['projectFullPath'],
  apollo: {
    commitSha: {
      query: getCommitSha,
    },
    pipeline: {
      query: getPipelineQuery,
      variables() {
        return {
          fullPath: this.projectFullPath,
          sha: this.commitSha,
        };
      },
      update: (data) => {
        return data.project?.pipeline;
      },
      error() {
        this.hasError = true;
      },
      pollInterval: POLL_INTERVAL,
    },
  },
  data() {
    return {
      hasError: false,
    };
  },
  computed: {
    commitPath() {
      return this.pipeline?.pipelineType?.commitPath || ''; // TODO
    },
    errorMessage() {
      return s__(FETCH_ERROR_MESSAGE);
    },
    hasPipelineData() {
      return Boolean(this.$apollo.queries.pipeline?.id);
    },
    isQueryLoading() {
      return this.$apollo.queries.pipeline.loading && !this.hasPipelineData;
    },
    pipelineId() {
      return this.pipeline?.id.match(/\d+/g)[0] || 0;
    },
    status() {
      return this.pipeline?.detailedStatus || {};
    },
    shortSha() {
      return this.pipeline?.pipelineType?.shortSha || ''; // TODO
    },
  },
};
</script>

<template>
  <div>
    <gl-loading-icon v-if="isQueryLoading" size="lg" class="gl-mt-3 gl-mb-3" />
    <gl-alert v-else-if="hasError" variant="danger">
      {{ errorMessage }}
    </gl-alert>
    <div v-else class="gl-display-flex gl-align-items-center">
      <a :href="status.detailsPath" class="align-self-start gl-mr-3">
        <ci-icon :status="status" :size="24" />
      </a>
      <div class="media-body">
        <div class="gl-font-weight-bold">
          {{ s__('Pipeline|Pipeline') }}
          <gl-link
            :href="status.detailsPath"
            class="pipeline-id gl-font-weight-normal pipeline-number"
            data-testid="pipeline-id"
          >
            #{{ pipelineId }}</gl-link
          >
          {{ status.text }}
          {{ s__('Pipeline|for') }}
          <gl-link
            :href="commitPath"
            class="commit-sha gl-font-weight-normal"
            data-testid="pipeline-commit"
          >
            {{ shortSha }}
          </gl-link>
        </div>
      </div>
    </div>
  </div>
</template>

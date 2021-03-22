<script>
import { GlAlert, GlSkeletonLoader, GlTable } from '@gitlab/ui';
import { __ } from '~/locale';
import GetJobs from './graphql/queries/get_jobs.query.graphql';

const DEFAULT_TD_CLASS = 'gl-p-5!';
const DEFAULT_TH_CLASSES =
  'gl-bg-transparent! gl-border-b-solid! gl-border-b-gray-100! gl-p-5! gl-border-b-1!';

export default {
  i18n: {
    errorMsg: __('There was an error fetching the jobs for your project.'),
  },
  fields: [
    {
      key: 'status',
      label: __('Status'),
      thClass: DEFAULT_TH_CLASSES,
      tdClass: DEFAULT_TD_CLASS,
    },
    {
      key: 'job',
      label: __('Job'),
      thClass: DEFAULT_TH_CLASSES,
      tdClass: DEFAULT_TD_CLASS,
    },
    {
      key: 'pipeline',
      label: __('Pipeline'),
      thClass: DEFAULT_TH_CLASSES,
      tdClass: DEFAULT_TD_CLASS,
    },
    {
      key: 'stage',
      label: __('Stage'),
      thClass: DEFAULT_TH_CLASSES,
      tdClass: DEFAULT_TD_CLASS,
    },
    {
      key: 'name',
      label: __('Name'),
      thClass: DEFAULT_TH_CLASSES,
      tdClass: DEFAULT_TD_CLASS,
    },
    {
      key: 'duration',
      label: __('Duration'),
      thClass: DEFAULT_TH_CLASSES,
      tdClass: DEFAULT_TD_CLASS,
    },
    {
      key: 'coverage',
      label: __('Coverage'),
      thClass: DEFAULT_TH_CLASSES,
      tdClass: DEFAULT_TD_CLASS,
    },
    {
      key: 'actions',
      label: '',
      thClass: DEFAULT_TH_CLASSES,
      tdClass: DEFAULT_TD_CLASS,
    },
  ],
  components: {
    GlAlert,
    GlSkeletonLoader,
    GlTable,
  },
  inject: {
    fullPath: {
      default: '',
    },
  },
  apollo: {
    jobs: {
      query: GetJobs,
      variables() {
        return {
          fullPath: this.fullPath,
        };
      },
      update(data) {
        const pipelines = data.project?.pipelines?.nodes;

        return pipelines.map((pipeline) => pipeline.jobs.nodes);
      },
      error() {
        this.error = true;
      },
    },
  },
  data() {
    return {
      jobs: null,
      error: false,
      isAlertDismissed: false,
    };
  },
  computed: {
    shouldShowAlert() {
      return this.error && !this.isAlertDismissed;
    },
  },
};
</script>

<template>
  <div>
    <gl-alert
      v-if="shouldShowAlert"
      class="gl-mt-2"
      variant="danger"
      dismissible
      @dismiss="isAlertDismissed = true"
    >
      {{ $options.i18n.errorMsg }}
    </gl-alert>
    <div v-if="$apollo.loading" class="gl-mt-5">
      <gl-skeleton-loader
        preserve-aspect-ratio="none"
        equal-width-lines
        :lines="5"
        :width="600"
        :height="66"
      />
    </div>
    <gl-table v-else :items="jobs" :fields="$options.fields" />
  </div>
</template>

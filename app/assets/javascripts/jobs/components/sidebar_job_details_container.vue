<script>
import { mapState } from 'vuex';
import DetailRow from './sidebar_detail_row.vue';
import { __, sprintf } from '~/locale';
import timeagoMixin from '~/vue_shared/mixins/timeago';
import { timeIntervalInWords } from '~/lib/utils/datetime_utility';

export default {
  name: 'SidebarJobDetailsContainer',
  components: {
    DetailRow,
  },
  mixins: [timeagoMixin],
  props: {
    runnerHelpUrl: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    ...mapState(['job']),
    coverage() {
      return `${this.job.coverage}%`;
    },
    duration() {
      return timeIntervalInWords(this.job.duration);
    },
    erasedAt() {
      return this.timeFormatted(this.job.erased_at);
    },
    finishedAt() {
      return this.timeFormatted(this.job.finished_at);
    },
    hasTimeout() {
      return Boolean(this.job?.metadata?.timeout_human_readable);
    },
    queued() {
      return timeIntervalInWords(this.job.queued);
    },
    renderBlock() {
      return (
        this.job.duration ||
        this.job.finished_at ||
        this.job.erased_at ||
        this.job.queued ||
        this.hasTimeout ||
        this.job.runner ||
        this.job.coverage ||
        this.job.tags.length
      );
    },
    runnerId() {
      return `${this.job.runner.description} (#${this.job.runner.id})`;
    },
    timeout() {
      if (this.job.metadata == null) {
        return '';
      }

      let t = this.job.metadata.timeout_human_readable;
      if (this.job.metadata.timeout_source !== '') {
        t += sprintf(__(` (from %{timeoutSource})`), {
          timeoutSource: this.job.metadata.timeout_source,
        });
      }

      return t;
    },
  },
};
</script>

<template>
  <div v-if="renderBlock" class="block">
    <detail-row v-if="job.duration" :value="duration" class="js-job-duration" title="Duration" />
    <detail-row
      v-if="job.finished_at"
      :value="finishedAt"
      class="js-job-finished"
      title="Finished"
    />
    <detail-row v-if="job.erased_at" :value="erasedAt" class="js-job-erased" title="Erased" />
    <detail-row v-if="job.queued" :value="queued" class="js-job-queued" title="Queued" />
    <detail-row
      v-if="hasTimeout"
      :help-url="runnerHelpUrl"
      :value="timeout"
      class="js-job-timeout"
      title="Timeout"
    />
    <detail-row v-if="job.runner" :value="runnerId" class="js-job-runner" title="Runner" />
    <detail-row v-if="job.coverage" :value="coverage" class="js-job-coverage" title="Coverage" />

    <p v-if="job.tags.length" class="build-detail-row js-job-tags">
      <span class="font-weight-bold">{{ __('Tags:') }}</span>
      <span v-for="(tag, i) in job.tags" :key="i" class="badge badge-primary mr-1">{{ tag }}</span>
    </p>
  </div>
</template>

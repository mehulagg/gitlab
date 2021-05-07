<script>
import { GlAlert, GlLink, GlSprintf } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import axios from '~/lib/utils/axios_utils';
import { n__, __ } from '~/locale';

export default {
  components: {
    GlAlert,
    GlLink,
    GlSprintf,
  },
  props: {
    upstreamFullPath: {
      type: String,
      required: true,
    },
    upstreamUrl: {
      type: String,
      required: true,
    },
    upstreamDefaultBranch: {
      type: String,
      required: true,
    },
    currentRef: {
      type: String,
      required: true,
    },
    upstreamCommitsPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      isLoading: true,
      commitsBehind: 0,
    };
  },
  computed: {
    message() {
      if (this.commitsBehind) {
        return n__(
          '%d commit behind of %{linkStart}%{linkEnd}',
          '%d commits behind of %{linkStart}%{linkEnd}',
          this.commitsBehind,
        );
      } else if (this.commitsAhead) {
        return n__(
          '%d commit ahead of %{linkStart}%{linkEnd}',
          '%d commits ahead of %{linkStart}%{linkEnd}',
          this.commitsAhead,
        );
      }

      return __('This branch is level with %{linkStart}%{linkEnd}');
    },
  },
  mounted() {
    this.fetchCommitCounts();
  },
  methods: {
    async fetchCommitCounts() {
      try {
        const { data } = await axios.get(this.upstreamCommitsPath, {
          params: { ref: this.currentRef },
        });

        this.commitsBehind = data.commits_behind;
        this.commitsAhead = data.commits_ahead;
        this.isLoading = false;
      } catch (error) {
        Sentry.captureException(error);
      }
    },
  },
};
</script>

<template>
  <gl-alert v-if="!isLoading" class="gl-mb-4" variant="info" :dismissible="false">
    <gl-sprintf :message="message">
      <template #link>
        <gl-link :href="upstreamUrl">{{ upstreamFullPath }}:{{ upstreamDefaultBranch }}</gl-link>
      </template>
    </gl-sprintf>
  </gl-alert>
</template>

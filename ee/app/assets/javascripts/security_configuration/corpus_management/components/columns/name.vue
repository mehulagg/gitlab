<script>
import { GlLink } from '@gitlab/ui';
import { numberToHumanSize } from '~/lib/utils/number_utils';
import { __ } from '~/locale';

export default {
  components: {
    GlLink,
  },
  props: {
    corpus: {
      type: Object,
      required: true,
    },
  },
  i18n: {
    latestJob: __('Latest Job:'),
  },
  computed: {
    fileSize() {
      return numberToHumanSize(this.corpus.size);
    },
    jobUrl() {
      // TODO: Replace with relative path when we complete backend
      return `https://www.gitlab.com/${this.corpus.latestJobPath}`;
    },
    jobPath() {
      return this.corpus.latestJobPath;
    },
    hasJobPath() {
      return Boolean(this.corpus.latestJobPath);
    },
  },
};
</script>
<template>
  <div>
    <div data-testid="corpus-name">
      <span>{{ corpus.name }}</span> <span>({{ fileSize }})</span>
    </div>
    <div data-testid="latest-job">
      <span>{{ this.$options.i18n.latestJob }}</span>
      <gl-link v-if="hasJobPath" class="gl-display-inline-block" :href="jobUrl" target="_blank">
        {{ jobPath }}
      </gl-link>
      <span v-else>-</span>
    </div>
  </div>
</template>

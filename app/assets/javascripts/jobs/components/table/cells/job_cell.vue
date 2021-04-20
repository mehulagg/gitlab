<script>
import { GlBadge, GlIcon, GlLink } from '@gitlab/ui';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';

export default {
  iconSize: 12,
  badgeSize: 'sm',
  components: {
    GlBadge,
    GlIcon,
    GlLink,
  },
  props: {
    job: {
      type: Object,
      required: true,
    },
  },
  computed: {
    jobId() {
      return getIdFromGraphQLId(this.job.id);
    },
    jobPath() {
      return this.job.detailedStatus?.detailsPath;
    },
    jobRef() {
      return this.job?.refName;
    },
    jobRefPath() {
      return this.job?.refPath;
    },
    jobTags() {
      return this.job.tags;
    },
    tag() {
      return false;
    },
    isManualJob() {
      return this.job.detailedStatus.action.title === 'Play';
    },
    successfulJob() {
      return this.job.status === 'SUCCESS';
    },
    showAllowedToFailLabel() {
      return this.job.allowedToFail && !this.successfulJob;
    },
  },
};
</script>

<template>
  <div>
    <div class="gl-display-flex gl-align-items-center">
      <gl-link class="gl-text-gray-500!" :href="jobPath">{{ `#${jobId}` }}</gl-link>

      <div v-if="jobRef">
        <gl-icon v-if="tag" name="label" :size="$options.iconSize" />
        <gl-icon v-else name="fork" :size="$options.iconSize" />
      </div>

      <gl-icon name="commit" class="gl-vertical-align-middle" :size="$options.iconSize" />
    </div>

    <div>
      <gl-badge v-for="tag in jobTags" :key="tag" variant="info" :size="$options.badgeSize">
        {{ tag }}
      </gl-badge>
      <gl-badge variant="info" :size="$options.badgeSize">{{ __('triggered') }}</gl-badge>
      <gl-badge v-if="showAllowedToFailLabel" variant="warning" :size="$options.badgeSize">{{
        __('allowed to fail')
      }}</gl-badge>
      <gl-badge variant="info" :size="$options.badgeSize">{{
        s__('DelayedJobs|delayed')
      }}</gl-badge>
      <gl-badge v-if="isManualJob" variant="info" :size="$options.badgeSize">
        {{ __('manual') }}</gl-badge
      >
    </div>
  </div>
</template>

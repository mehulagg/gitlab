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
    createdByTag() {
      return false;
    },
    triggered() {
      return false;
    },
    isManualJob() {
      return this.job.detailedStatus.action.title === 'Play';
    },
    successfulJob() {
      return this.job.status === 'SUCCESS';
    },
    allowedToFail() {
      return this.job.allowedToFail && !this.successfulJob;
    },
    scheduledJob() {
      return this.job.scheduledAt;
    },
  },
};
</script>

<template>
  <div>
    <div class="gl-text-truncate">
      <gl-link class="gl-text-gray-500!" :href="jobPath">{{ `#${jobId}` }}</gl-link>

      <div class="gl-display-flex gl-align-items-center">
        <div v-if="jobRef">
          <gl-icon v-if="createdByTag" name="label" :size="$options.iconSize" />
          <gl-icon v-else name="fork" :size="$options.iconSize" />
          <gl-link class="gl-font-weight-bold gl-text-gray-500!" :href="job.refPath">{{
            job.refName
          }}</gl-link>
        </div>

        <gl-icon class="gl-ml-2 gl-mr-2" name="commit" :size="$options.iconSize" />

        <gl-link :href="job.commitPath">{{ job.shortSha }}</gl-link>
      </div>
    </div>

    <div>
      <gl-badge v-for="tag in jobTags" :key="tag" variant="info" :size="$options.badgeSize">
        {{ tag }}
      </gl-badge>

      <gl-badge v-if="triggered" variant="info" :size="$options.badgeSize">{{
        __('triggered')
      }}</gl-badge>
      <gl-badge v-if="allowedToFail" variant="warning" :size="$options.badgeSize">{{
        __('allowed to fail')
      }}</gl-badge>
      <gl-badge v-if="scheduledJob" variant="info" :size="$options.badgeSize">{{
        s__('DelayedJobs|delayed')
      }}</gl-badge>
      <gl-badge v-if="isManualJob" variant="info" :size="$options.badgeSize">
        {{ __('manual') }}</gl-badge
      >
    </div>
  </div>
</template>

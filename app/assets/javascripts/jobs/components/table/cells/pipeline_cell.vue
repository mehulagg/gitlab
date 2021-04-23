<script>
import { GlAvatar, GlLink } from '@gitlab/ui';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';

export default {
  components: {
    GlAvatar,
    GlLink,
  },
  props: {
    job: {
      type: Object,
      required: true,
    },
  },
  computed: {
    pipelineId() {
      const id = getIdFromGraphQLId(this.job.pipeline.id);
      return `#${id}`;
    },
    pipelinePath() {
      return this.job.pipeline?.path;
    },
    pipelineUserAvatar() {
      return this.job.pipeline?.user?.avatarUrl;
    },
    userPath() {
      return this.job.pipeline?.user?.webPath;
    },
    showAvatar() {
      return this.job.pipeline?.user;
    },
  },
};
</script>

<template>
  <div>
    <gl-link class="gl-text-gray-500!" :href="pipelinePath">{{ pipelineId }}</gl-link>
    <div>
      <span>{{ __('created by') }}</span>
      <gl-link v-if="showAvatar" :href="userPath">
        <gl-avatar :src="pipelineUserAvatar" :size="16" />
      </gl-link>
      <span v-else>{{ __('API') }}</span>
    </div>
  </div>
</template>

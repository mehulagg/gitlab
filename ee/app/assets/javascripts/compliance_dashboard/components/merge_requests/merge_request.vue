<script>
import { GlAvatar, GlAvatarLink } from '@gitlab/ui';

import { s__ } from '~/locale';

export default {
  components: {
    GlAvatar,
    GlAvatarLink,
  },
  props: {
    mergeRequest: {
      type: Object,
      required: true,
    },
  },
  strings: {
    createdBy: s__('ComplianceDashboard|created by:'),
  },
};
</script>

<template>
  <div
    class="gl-grid-col-start-1 gl-border-b-solid gl-border-b-1 gl-border-b-gray-100 gl-p-5"
    data-testid="merge-request"
  >
    <a :href="mergeRequest.path" class="gl-display-block gl-text-gray-900 gl-font-weight-bold">
      {{ mergeRequest.title }}
    </a>
    <span class="gl-text-gray-500">{{ mergeRequest.issuable_reference }}</span>
    <span class="issuable-authored gl-text-gray-500 gl-display-inline-flex gl-align-items-center">
      - {{ $options.strings.createdBy }}
      <gl-avatar-link
        :key="mergeRequest.author.id"
        :title="mergeRequest.author.name"
        :href="mergeRequest.author.web_url"
        :data-user-id="mergeRequest.author.id"
        :data-name="mergeRequest.author.name"
        class="gl-display-inline-flex gl-align-items-center gl-ml-3 gl-text-gray-900 author-link js-user-link"
      >
        <gl-avatar
          :src="mergeRequest.author.avatar_url"
          :entity-id="mergeRequest.author.id"
          :entity-name="mergeRequest.author.name"
          :size="16"
          class="gl-mr-2"
        />
        <span>{{ mergeRequest.author.name }}</span>
      </gl-avatar-link>
    </span>
  </div>
</template>

<script>
import { GlBadge, GlPopover, GlIcon } from '@gitlab/ui';

export default {
  components: {
    GlBadge,
    GlIcon,
    GlPopover,
  },
  props: {
    popoverId: {
      type: String,
      required: true,
    },
    mergeRequests: {
      type: Object,
      required: true
    }
  },
  methods: {
    getIconColor (status) {
      if (status === 'status_success') {
        return 'gl-text-green-500';
      } else if (status === 'status_failed' || status === 'status_canceled') {
        return 'gl-text-red-500';
      } else if (status === 'status_pending' || status === 'status_warning') {
        return 'gl-text-orange-500';
      } else if (status === 'merge') {
        return 'gl-text-blue-500';
      }
      return 'gl-text-gray-500';
    }
  }
};
</script>

<template>
  <div :id="popoverId">
    <gl-badge
    data-testid="vulnerability-solutions-bulb"
    variant="neutral"
    icon="merge-request"
    />

    <gl-popover :container="popoverId" :target="popoverId" placement="top" triggers="hover focus">
      <template #title>
        <span>{{mergeRequests.nodes.length}}{{s__('AutoRemediation| Merge Request')}}</span>
      </template>
      <ul class="gl-list-style-none gl-pl-0 gl-mb-0">
        <li v-for="item in mergeRequests.nodes" :key="item.merge_request.url" class="gl-align-items-center gl-display-flex gl-mb-2">        
          <gl-icon :name="item.merge_request.status" :size="16" :class="getIconColor(item.merge_request.status)" />
          <a :href="item.merge_request.url" class="gl-ml-3">
            <span>!{{item.merge_request.url.split("/")[item.merge_request.url.split("/").length - 1]}}<span v-if="item.merge_request.auto_fix">{{s__('AutoRemediation|: Auto-fix')}}</span></span>
          </a>
        </li>
      </ul>
    </gl-popover>
  </div>
</template>

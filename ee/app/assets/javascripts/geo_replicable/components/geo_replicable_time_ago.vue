<script>
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';

export default {
  name: 'GeoReplicableTimeAgo',
  components: {
    TimeAgo,
  },
  props: {
    label: {
      type: String,
      required: true,
    },
    defaultText: {
      type: String,
      required: true,
    },
    dateString: {
      type: String,
      required: false,
      default: '',
    },
  },
};
</script>

<template>
  <div class="d-flex flex-column">
    <label class="text-muted">{{ label }}</label>
    <time-ago v-if="dateString" :time="dateString" tooltip-placement="bottom" />
    <span v-else>{{ defaultText }}</span>
  </div>
</template>

<script>
import { GlSprintf } from '@gitlab/ui';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import { datePropValidator } from '../utils';

export default {
  name: 'CreatedAt',
  components: { GlSprintf, TimeAgoTooltip },
  props: {
    date: {
      validator: datePropValidator,
      required: true,
    },
    createdBy: {
      type: Object,
      required: false,
      default: null,
    },
  },
  computed: {
    showCreatedBy() {
      return this.createdBy?.name && this.createdBy?.webUrl;
    },
  },
};
</script>

<template>
  <span>
    <gl-sprintf v-if="showCreatedBy" :message="__('%{time} by %{user}')">
      <template #time>
        <time-ago-tooltip :time="date" />
      </template>
      <template #user>
        <a :href="createdBy.webUrl">{{ createdBy.name }}</a>
      </template>
    </gl-sprintf>
    <time-ago-tooltip v-else :time="date" />
  </span>
</template>

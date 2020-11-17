<script>
import { AVAILABILITY_STATUS, isUserBusy } from '../utils';

export default {
  name: 'UserAvailabilityStatus',
  props: {
    status: {
      type: Object,
      required: true,
      default: () => ({
        availability: '',
      }),
    },
  },
  computed: {
    isBusy() {
      const {
        status: { availability = AVAILABILITY_STATUS.NOT_SET },
      } = this;
      return isUserBusy(availability);
    },
  },
};
</script>

<template>
  <span v-if="isBusy" class="gl-font-weight-normal gl-text-gray-600">{{
    s__('UserAvailability|(Busy)')
  }}</span>
</template>

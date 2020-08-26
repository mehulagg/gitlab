<script>
import { mapState, mapActions } from 'vuex';

import Subscription from '~/sidebar/components/subscriptions/subscriptions.vue';

export default {
  components: {
    Subscription,
  },
  props: {
    sidebarCollapsed: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    ...mapState(['subscribed', 'epicSubscriptionToggleInProgress']),
  },
  methods: {
    ...mapActions(['toggleSidebar', 'toggleEpicSubscription']),
  },

  emits: [],
};
</script>

<template>
  <div class="block subscription">
    <subscription
      :loading="epicSubscriptionToggleInProgress"
      :subscribed="subscribed"
      @toggleSubscription="toggleEpicSubscription"
      @toggleSidebar="toggleSidebar({ sidebarCollapsed })"
    />
  </div>
</template>

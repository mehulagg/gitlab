<script>
import { mapActions } from 'vuex';
import { GlButton, GlLink } from '@gitlab/ui';
import StatusFilter from './status_filter.vue';
import ConfidentialityFilter from './confidentiality_filter.vue';

export default {
  name: 'GlobalSearchSidebar',
  components: {
    GlButton,
    GlLink,
    StatusFilter,
    ConfidentialityFilter,
  },
  methods: {
    ...mapActions(['applyQuery', 'resetQuery']),
  },
};
</script>

<template>
  <section class="gl-display-flex gl-flex-direction-column col-md-3 gl-mr-4">
    <status-filter />
    <hr class="gl-my-3 gl-border-gray-200" />
    <confidentiality-filter />
    <hr class="gl-my-3 gl-border-gray-200" />
    <div class="gl-display-flex gl-align-items-flex-end gl-mt-2">
      <gl-button variant="success" @click="applyQuery">{{ __('Apply') }}</gl-button>
      <gl-link class="gl-ml-auto" @click="resetQuery">{{ __('Reset filters') }}</gl-link>
    </div>
  </section>
</template>

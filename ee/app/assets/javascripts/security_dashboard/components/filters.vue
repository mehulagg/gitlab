<script>
import { mapActions } from 'vuex';
import { severityFilter, scannerFilter } from 'ee/security_dashboard/helpers';
import StandardFilter from './filters/standard_filter.vue';
import GlToggleVuex from '~/vue_shared/components/gl_toggle_vuex.vue';

export default {
  components: {
    StandardFilter,
    GlToggleVuex,
  },
  data: () => ({
    filters: [severityFilter, scannerFilter],
  }),
  methods: {
    ...mapActions('filters', ['setFilter']),
  },
};
</script>

<template>
  <div class="dashboard-filters border-bottom bg-gray-light">
    <div class="row mx-0 p-2">
      <standard-filter
        v-for="filter in filters"
        :key="filter.id"
        class="col-sm-6 col-md-4 col-lg-2 p-2 js-filter"
        :filter="filter"
        @filter-changed="setFilter"
      />
      <div class="gl-display-flex ml-lg-auto p-2">
        <slot name="buttons"></slot>
        <div class="pl-md-6">
          <strong>{{ s__('SecurityReports|Hide dismissed') }}</strong>
          <gl-toggle-vuex
            class="d-block mt-1 js-toggle"
            store-module="filters"
            state-property="hideDismissed"
            set-action="setToggleValue"
          />
        </div>
      </div>
    </div>
  </div>
</template>

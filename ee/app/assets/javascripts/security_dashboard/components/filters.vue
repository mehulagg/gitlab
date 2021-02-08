<script>
import { mapState, mapActions } from 'vuex';
import { GlToggle } from '@gitlab/ui';
import { severityFilter, scannerFilter } from 'ee/security_dashboard/helpers';
import { DISMISSAL_STATES } from '../store/modules/filters/constants';
import StandardFilter from './filters/standard_filter.vue';

export default {
  components: {
    StandardFilter,
    GlToggle,
  },
  data: () => ({
    filterConfigs: [severityFilter, scannerFilter],
  }),
  computed: {
    ...mapState('filters', ['filters']),
    hideDismissed: {
      set(isHidden) {
        this.setHideDismissed(isHidden);
      },
      get() {
        return this.filters.scope === DISMISSAL_STATES.DISMISSED;
      },
    },
  },
  methods: {
    ...mapActions('filters', ['setFilter', 'setHideDismissed']),
  },
};
</script>

<template>
  <div class="dashboard-filters border-bottom bg-gray-light">
    <div class="row mx-0 p-2">
      <standard-filter
        v-for="filter in filterConfigs"
        :key="filter.id"
        class="col-sm-6 col-md-4 col-lg-2 p-2 js-filter"
        :filter="filter"
        @filter-changed="setFilter"
      />
      <div class="gl-display-flex ml-lg-auto p-2">
        <slot name="buttons"></slot>
        <div class="pl-md-6">
          <strong>{{ s__('SecurityReports|Hide dismissed') }}</strong>
          <gl-toggle v-model="hideDismissed" class="gl-mt-2 js-toggle" />
        </div>
      </div>
    </div>
  </div>
</template>

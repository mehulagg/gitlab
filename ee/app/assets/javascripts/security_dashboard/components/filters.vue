<script>
import { mapGetters, mapActions } from 'vuex';
import DashboardFilter from './filter.vue';
import GlToggleVuex from '~/vue_shared/components/gl_toggle_vuex.vue';

export default {
  components: {
    DashboardFilter,
    GlToggleVuex,
  },
  computed: {
    ...mapGetters('filters', ['visibleFilters']),
  },
  methods: {
    ...mapActions('filters', ['setFilter']),
  },
};
</script>

<template>
  <div class="dashboard-filters border-bottom bg-gray-light">
    <div class="row mx-0 p-2">
      <dashboard-filter
        v-for="filter in visibleFilters"
        :key="filter.id"
        class="col-sm-6 col-md-4 col-lg-2 p-2 js-filter"
        :filter="filter"
        @setFilter="setFilter"
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

<script>
import { mapActions, mapState } from 'vuex';
import AuditEventsFilter from './audit_events_filter.vue';
import DateRangeField from './date_range_field.vue';
import SortingField from './sorting_field.vue';
import AuditEventsTable from './audit_events_table.vue';

export default {
  components: {
    AuditEventsFilter,
    DateRangeField,
    SortingField,
    AuditEventsTable,
  },
  props: {
    events: {
      type: Array,
      required: false,
      default: () => [],
    },
    isLastPage: {
      type: Boolean,
      required: false,
      default: false,
    },
    filterTokenOptions: {
      type: Array,
      required: true,
    },
    filterQaSelector: {
      type: String,
      required: false,
      default: undefined,
    },
    tableQaSelector: {
      type: String,
      required: false,
      default: undefined,
    },
  },
  computed: {
    ...mapState(['filterValue', 'startDate', 'endDate', 'sortBy']),
  },
  methods: {
    ...mapActions(['setDateRange', 'setFilterValue', 'setSortBy', 'searchForAuditEvents']),
  },
};
</script>

<template>
  <div>
    <div class="row-content-block second-block gl-pb-0">
      <div class="gl-display-flex gl-justify-content-space-between audit-controls gl-flex-wrap">
        <div class="gl-mb-5 gl-w-full">
          <audit-events-filter
            :filter-token-options="filterTokenOptions"
            :qa-selector="filterQaSelector"
            :value="filterValue"
            @selected="setFilterValue"
            @submit="searchForAuditEvents"
          />
        </div>
        <div class="gl-display-flex gl-flex-wrap gl-w-full">
          <div
            class="audit-controls gl-display-flex flex-column flex-lg-row col-lg-auto gl-justify-content-space-between px-0 gl-w-full"
          >
            <date-range-field
              :start-date="startDate"
              :end-date="endDate"
              @selected="setDateRange"
            />
            <sorting-field :sort-by="sortBy" @selected="setSortBy" />
          </div>
        </div>
      </div>
    </div>
    <audit-events-table
      :events="events"
      :is-last-page="isLastPage"
      :qa-selector="tableQaSelector"
    />
  </div>
</template>

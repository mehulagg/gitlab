<script>
import { mapActions, mapState, mapGetters } from 'vuex';
import AuditEventsFilter from './audit_events_filter.vue';
import DateRangeField from './date_range_field.vue';
import SortingField from './sorting_field.vue';
import AuditEventsTable from './audit_events_table.vue';
import AuditEventsExportButton from './audit_events_export_button.vue';

export default {
  components: {
    AuditEventsFilter,
    DateRangeField,
    SortingField,
    AuditEventsTable,
    AuditEventsExportButton,
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
    exportUrl: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    ...mapState(['filterValue', 'startDate', 'endDate', 'sortBy']),
    ...mapGetters(['buildExportHref']),
    exportHref() {
      return this.buildExportHref(this.exportUrl);
    },
    hasExportUrl() {
      return this.exportUrl.length;
    },
  },
  methods: {
    ...mapActions(['setDateRange', 'setFilterValue', 'setSortBy', 'searchForAuditEvents']),
  },
};
</script>

<template>
  <div>
    <header>
      <div class="gl-my-5 gl-display-flex gl-flex-direction-row gl-justify-content-end">
        <audit-events-export-button v-if="hasExportUrl" :export-href="exportHref" />
      </div>
    </header>
    <div class="row-content-block second-block pb-0">
      <div class="d-flex justify-content-between audit-controls row">
        <div class="col-lg-auto flex-fill form-group align-items-lg-center pr-lg-8">
          <audit-events-filter
            :filter-token-options="filterTokenOptions"
            :value="filterValue"
            @selected="setFilterValue"
            @submit="searchForAuditEvents"
          />
        </div>
        <div class="d-flex col-lg-auto flex-wrap pl-lg-0">
          <div
            class="audit-controls d-flex align-items-lg-center flex-column flex-lg-row col-lg-auto px-0"
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
    <audit-events-table :events="events" :is-last-page="isLastPage" />
  </div>
</template>

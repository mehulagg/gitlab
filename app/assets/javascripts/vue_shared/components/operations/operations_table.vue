<script>
import {
  GlLoadingIcon,
  GlTable,
} from '@gitlab/ui';

const tdClass =
  'table-col gl-display-flex d-md-table-cell gl-align-items-center gl-white-space-nowrap';
const thClass = 'gl-hover-bg-blue-50';
const bodyTrClass =
  'gl-border-1 gl-border-t-solid gl-border-gray-100 gl-hover-bg-blue-50 gl-hover-cursor-pointer gl-hover-border-b-solid gl-hover-border-blue-200';
const TH_TEST_ID = { 'data-testid': 'alert-management-severity-sort' };


export default {
  components: {
    GlLoadingIcon,
    GlTable,
  },
  props: {
    items: {
      type: Array,
      required: true,
    },
    fields: {
        type: Array,
      required: true,
    },
    loading: {
      type: Boolean,
      required: false,
    },
  },
  data() {
    return {
      sort: 'STARTED_AT_DESC',
      sortBy: 'startedAt',
      sortDesc: true,
      sortDirection: 'desc',
    };
  },
  computed: {
    hasItems() {
      return this.items?.length || this.items?.list?.length;
    },
  },
  methods: {
    tbodyTrClass(item) {
      return {
        [bodyTrClass]: !this.loading && this.hasItems,
        'new-alert': item?.isNew,
      };
    },
    slotShortHandName({ key }) {
        return `cell(${key})`;
    }
  },
};
</script>
<template>
    <div class="incident-management-list">
      <h4 class="d-block d-md-none my-3">
        {{ s__('AlertManagement|Alerts') }}
      </h4>
      <gl-table
        class="alert-management-table"
        :items="items ? items.list : []"
        :fields="fields"
        :show-empty="true"
        :busy="loading"
        stacked="md"
        :tbody-tr-class="tbodyTrClass"
        :no-local-sorting="true"
        :sort-direction="sortDirection"
        :sort-desc.sync="sortDesc"
        :sort-by.sync="sortBy"
        sort-icon-left
        fixed
        @row-clicked="() => {}"
        @sort-changed="() => {}"
      >

        <slot v-for="item in items" :name="slotShortHandName(item)"></slot>
       
        <template #empty>
          {{ s__('AlertManagement|No alerts to display.') }}
        </template>

        <template #table-busy>
          <gl-loading-icon size="lg" color="dark" class="mt-3" />
        </template>
      </gl-table>
    </div>
</template>

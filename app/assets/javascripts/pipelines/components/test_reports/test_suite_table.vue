<script>
import { mapGetters } from 'vuex';
import SmartVirtualList from '~/vue_shared/components/smart_virtual_list.vue';
import { __ } from '~/locale';
import TestSuiteTableRow from './test_suite_table_row.vue';

export default {
  name: 'TestsSuiteTable',
  components: {
    SmartVirtualList,
  },
  props: {
    heading: {
      type: String,
      required: false,
      default: __('Tests'),
    },
  },
  data() {
    return {
      rowComponent: TestSuiteTableRow,
    };
  },
  computed: {
    ...mapGetters(['getSuiteTests']),
    hasSuites() {
      return this.getSuiteTests.length > 0;
    },
  },
  maxShownRows: 30,
  typicalRowHeight: 75,
};
</script>

<template>
  <div>
    <div class="row gl-mt-3">
      <div class="col-12">
        <h4>{{ heading }}</h4>
      </div>
    </div>

    <div v-if="hasSuites" class="test-reports-table gl-mb-3 js-test-cases-table">
      <div role="row" class="gl-responsive-table-row table-row-header font-weight-bold fgray">
        <div role="rowheader" class="table-section section-20">
          {{ __('Suite') }}
        </div>
        <div role="rowheader" class="table-section section-20">
          {{ __('Name') }}
        </div>
        <div role="rowheader" class="table-section section-10 text-center">
          {{ __('Status') }}
        </div>
        <div role="rowheader" class="table-section flex-grow-1">
          {{ __('Trace'), }}
        </div>
        <div role="rowheader" class="table-section section-10 text-right">
          {{ __('Duration') }}
        </div>
      </div>

      <smart-virtual-list
        :data-key="'key'"
        :data-sources="getSuiteTests"
        :data-component="rowComponent"
        :keeps="$options.maxShownRows"
        :estimate-size="$options.typicalRowHeight"
        style="display: block; overflow-y: auto; height: 900px;"
      />
    </div>

    <div v-else>
      <p class="js-no-test-cases">{{ s__('TestReports|There are no test cases to display.') }}</p>
    </div>
  </div>
</template>

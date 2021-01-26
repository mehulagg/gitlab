<script>
import { GlBadge, GlFormSelect, GlTab, GlTabs } from '@gitlab/ui';
import { differenceBy, unionBy } from 'lodash';
import LabelsSelect from '~/vue_shared/components/sidebar/labels_select_vue/labels_select_root.vue';
import { GroupBy, Namespace } from '../constants';
import { DropdownVariant } from '~/vue_shared/components/sidebar/labels_select_vue/constants';
import IterationReportIssues from './iteration_report_issues.vue';
import { __ } from '~/locale';

export default {
  selectOptions: [
    {
      value: GroupBy.None,
      text: __('None'),
    },
    {
      value: GroupBy.Label,
      text: __('Label'),
    },
  ],
  variant: DropdownVariant.Standalone,
  components: {
    GlBadge,
    GlFormSelect,
    GlTab,
    GlTabs,
    IterationReportIssues,
    LabelsSelect,
  },
  props: {
    fullPath: {
      type: String,
      required: true,
    },
    iterationId: {
      type: String,
      required: true,
    },
    labelsFetchPath: {
      type: String,
      required: false,
      default: '',
    },
    namespaceType: {
      type: String,
      required: false,
      default: Namespace.Group,
      validator: (value) => Object.values(Namespace).includes(value),
    },
  },
  data() {
    return {
      issueCount: undefined,
      groupBySelection: GroupBy.None,
      selectedLabels: [],
    };
  },
  computed: {
    shouldShowFilterByLabel() {
      return this.groupBySelection === GroupBy.Label;
    },
  },
  methods: {
    handleIssueCount(count) {
      this.issueCount = count;
    },
    handleSelectChange() {
      if (this.groupBySelection === GroupBy.None) {
        this.selectedLabels = [];
      }
    },
    handleUpdateSelectedLabels(labels) {
      const labelsToAdd = labels.filter((label) => label.set);
      const labelsToRemove = labels.filter((label) => !label.set);
      const idProperty = 'id';

      this.selectedLabels = unionBy(
        differenceBy(this.selectedLabels, labelsToRemove, idProperty),
        labelsToAdd,
        idProperty,
      );
    },
  },
};
</script>

<template>
  <gl-tabs>
    <gl-tab title="Issues">
      <template #title>
        <span>{{ __('Issues') }}</span
        ><gl-badge class="gl-ml-2" variant="neutral">{{ issueCount }}</gl-badge>
      </template>

      <div class="card gl-bg-gray-10 gl-display-flex gl-flex-direction-row gl-flex-wrap gl-px-4">
        <div class="gl-my-3">
          <label for="iteration-group-by">{{ __('Group by') }}</label>
          <gl-form-select
            id="iteration-group-by"
            v-model="groupBySelection"
            class="gl-w-auto"
            :options="$options.selectOptions"
            @change="handleSelectChange"
          />
        </div>

        <div
          v-if="shouldShowFilterByLabel"
          class="gl-display-flex gl-align-items-center gl-flex-basis-half gl-white-space-nowrap gl-my-3 gl-ml-4"
        >
          <label class="gl-mb-0 gl-mr-2">{{ __('Filter by label') }}</label>
          <labels-select
            :allow-label-create="false"
            :allow-label-edit="true"
            :allow-multiselect="true"
            :allow-scoped-labels="true"
            :labels-fetch-path="labelsFetchPath"
            :selected-labels="selectedLabels"
            :variant="$options.variant"
            @updateSelectedLabels="handleUpdateSelectedLabels"
          />
        </div>
      </div>

      <iteration-report-issues
        v-for="label in selectedLabels"
        :key="label.id"
        class="gl-mb-6"
        :full-path="fullPath"
        :iteration-id="iterationId"
        :label="label"
        :namespace-type="namespaceType"
        :data-testid="`iteration-label-group-${label.id}`"
      />

      <iteration-report-issues
        v-show="!selectedLabels.length"
        :full-path="fullPath"
        :iteration-id="iterationId"
        :namespace-type="namespaceType"
        @issueCount="handleIssueCount"
      />
    </gl-tab>
  </gl-tabs>
</template>

<script>
import { GlBadge, GlFormSelect, GlLabel, GlTab, GlTabs } from '@gitlab/ui';
import { differenceBy, unionBy } from 'lodash';
import { __ } from '~/locale';
import LabelsSelect from '~/vue_shared/components/sidebar/labels_select_vue/labels_select_root.vue';
import { Namespace } from '../constants';
import { DropdownVariant } from '~/vue_shared/components/sidebar/labels_select_vue/constants';
import IterationReportIssues from './iteration_report_issues.vue';

export default {
  selectOptions: [
    {
      value: 'none',
      text: __('None'),
    },
    {
      value: 'label',
      text: __('Label'),
    },
  ],
  variant: DropdownVariant.Standalone,
  components: {
    GlBadge,
    GlFormSelect,
    GlLabel,
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
      groupBySelection: 'none',
      isLabelsSelectInProgress: false,
      selectedLabels: [],
    };
  },
  methods: {
    handleIssueCount(count) {
      this.issueCount = count;
    },
    handleSelectChange() {
      if (this.groupBySelection === 'none') {
        this.selectedLabels = [];
      }
    },
    handleUpdateSelectedLabels(labels) {
      const labelsToAdd = labels.filter((label) => label.set);
      const labelsToRemove = labels.filter((label) => !label.set);

      this.selectedLabels = unionBy(
        differenceBy(this.selectedLabels, labelsToRemove, 'id'),
        labelsToAdd,
        'id',
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
        ><gl-badge class="ml-2" variant="neutral">{{ issueCount }}</gl-badge>
      </template>

      <div class="card gl-bg-gray-10 gl-px-4 gl-display-flex gl-flex-wrap gl-flex-direction-row">
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
          v-if="groupBySelection === 'label'"
          class="gl-flex-basis-half gl-white-space-nowrap gl-my-3 gl-ml-5"
        >
          <label>{{ __('Filter by label') }}</label>
          <labels-select
            :allow-label-create="false"
            :allow-label-edit="true"
            :allow-multiselect="true"
            :allow-scoped-labels="true"
            inline
            :labels-fetch-path="labelsFetchPath"
            :labels-select-in-progress="isLabelsSelectInProgress"
            :selected-labels="selectedLabels"
            :variant="$options.variant"
            data-qa-selector="labels_block"
            @updateSelectedLabels="handleUpdateSelectedLabels"
          />
        </div>
      </div>

      <div v-for="label in selectedLabels" :key="label.id" class="gl-mb-8">
        <gl-label
          class="gl-ml-5"
          :background-color="label.color"
          :title="label.title"
          :description="label.description"
          :scoped="label.scoped"
        />
        <iteration-report-issues
          :full-path="fullPath"
          :iteration-id="iterationId"
          :label-name="label.title"
          :namespace-type="namespaceType"
        />
      </div>

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

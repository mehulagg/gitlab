<script>
import LabelsSelect from '~/vue_shared/components/sidebar/labels_select_vue/labels_select_root.vue';
import AssigneeTitle from '~/sidebar/components/assignees/assignee_title.vue';
import Assignee from './single_assignee.vue';

export default {
  components: {
    LabelsSelect,
    Assignee,
    AssigneeTitle,
  },
  props: {
    sidebarExpanded: {
      type: Boolean,
      required: true,
    },
    issue: {
      type: Object,
      required: true,
    },
    rootPath: {
      type: String,
      required: true,
    },
  },
  computed: {
    assignee() {
      // Jira issues only have (at most) one assignee
      return this.issue.assignees[0];
    },
  },
};
</script>

<template>
  <div>
    <div class="block">
      <assignee-title
        :number-of-assignees="1"
        :editable="false"
        :show-toggle="false"
        :changing="false"
      />
      <assignee :user="assignee" :collapsed="!sidebarExpanded" issuable-type="issue">
        <template #username>
          <div class="gl-text-gray-500">{{ __('Jira user') }}</div>
        </template>
      </assignee>
    </div>
    <labels-select
      :selected-labels="issue.labels.map((l) => ({ ...l, title: l.name }))"
      variant="sidebar"
      class="block labels js-labels-block"
    >
      {{ __('None') }}
    </labels-select>
  </div>
</template>

<script>
import { s__ } from '~/locale';
import SmartVirtualList from '~/vue_shared/components/smart_virtual_list.vue';
import GroupedIssuesListRow from './grouped_issues_list_row.vue';

export default {
  components: {
    SmartVirtualList,
  },
  props: {
    component: {
      type: String,
      required: false,
      default: '',
    },
    resolvedIssues: {
      type: Array,
      required: false,
      default: () => [],
    },
    unresolvedIssues: {
      type: Array,
      required: false,
      default: () => [],
    },
    resolvedHeading: {
      type: String,
      required: false,
      default: s__('ciReport|Fixed'),
    },
    unresolvedHeading: {
      type: String,
      required: false,
      default: s__('ciReport|New'),
    },
  },
  data() {
    return {
      groupedIssuesListRow: GroupedIssuesListRow,
    };
  },
  groups: ['unresolved', 'resolved'],
  typicalReportItemHeight: 32,
  maxShownReportItems: 20,
  computed: {
    extraPropsForRow() {
      return {
        component: this.component,
      }
    },
    groups() {
      return this.$options.groups
        .map(group => ({
          name: group,
          issues: this[`${group}Issues`],
          heading: this[`${group}Heading`],
        }))
        .filter(({ issues }) => issues.length > 0);
    },
    listLength() {
      // every group has a header which is rendered as a list item
      const groupsCount = this.groups.length;
      const issuesCount = this.groups.reduce(
        (totalIssues, { issues }) => totalIssues + issues.length,
        0,
      );

      return groupsCount + issuesCount;
    },
  },
};
</script>

<template>
  <smart-virtual-list
    data-key="name"
    :data-sources="groups"
    :data-component="groupedIssuesListRow"
    :extra-props="extraPropsForRow"
    :remain="$options.maxShowReportItems"
    :estimate-size="$options.typicalReportItemHeight"
    class="report-block-container"
    wrap-tag="ul"
    wrap-class="report-block-list"
  />
</template>

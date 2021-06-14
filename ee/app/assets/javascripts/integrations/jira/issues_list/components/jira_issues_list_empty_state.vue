<script>
import { GlEmptyState, GlButton, GlIcon, GlSprintf } from '@gitlab/ui';
import { IssuableStates } from '~/issuable_list/constants';
import { __, s__ } from '~/locale';

export default {
  FilterStateEmptyMessage: {
    [IssuableStates.Opened]: __('There are no open issues'),
    [IssuableStates.Closed]: __('There are no closed issues'),
  },
  components: {
    GlEmptyState,
    GlButton,
    GlIcon,
    GlSprintf,
  },
  inject: ['emptyStatePath', 'issueCreateUrl'],
  props: {
    currentState: {
      type: String,
      required: true,
    },
    issuesCount: {
      type: Object,
      required: true,
    },
    hasFiltersApplied: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    hasIssues() {
      return this.issuesCount[IssuableStates.Opened] + this.issuesCount[IssuableStates.Closed] > 0;
    },
    emptyStateTitle() {
      if (this.hasFiltersApplied) {
        return __('Sorry, your filter produced no results');
      } else if (this.hasIssues) {
        return this.$options.FilterStateEmptyMessage[this.currentState];
      }
      return s__(
        'Integrations|Issues created in Jira are shown here once you have created the issues in project setup in Jira.',
      );
    },
    emptyStateDescription() {
      if (this.hasFiltersApplied) {
        return __('To widen your search, change or remove filters above');
      } else if (!this.hasIssues) {
        return s__('Integrations|To keep this project going, create a new issue.');
      }
      return '';
    },
  },
};
</script>

<template>
  <gl-empty-state :svg-path="emptyStatePath" :title="emptyStateTitle">
    <template v-if="!hasIssues || hasFiltersApplied" #description>
      <gl-sprintf :message="emptyStateDescription" />
    </template>
    <template v-if="!hasIssues" #actions>
      <gl-button :href="issueCreateUrl" target="_blank" variant="confirm">
        {{ s__('Integrations|Create new issue in Jira') }}
        <gl-icon name="external-link" />
      </gl-button>
    </template>
  </gl-empty-state>
</template>

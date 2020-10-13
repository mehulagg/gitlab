<script>
import { GlEmptyState, GlSafeHtmlDirective as SafeHtml } from '@gitlab/ui';
import { __ } from '~/locale';
import { emptyStateHelper } from '../service_desk_helper';
import { IssuesState, IssuesListType } from '../constants';

export default {
  directives: {
    SafeHtml,
  },
  components: {
    GlEmptyState,
  },
  inject: ['emptyStateMeta', 'type'],
  props: {
    hasFilters: {
      type: Boolean,
      required: true,
    },
    issuesState: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    isServiceDesk() {
      return this.type === IssuesListType.serviceDesk;
    },
    emptyState() {
      if (this.isServiceDesk) {
        return emptyStateHelper(this.emptyStateMeta);
      }

      if (this.hasFilters) {
        return {
          title: __('Sorry, your filter produced no results'),
          svgPath: this.emptyStateMeta.svgPath,
          description: __('To widen your search, change or remove filters above'),
          primaryLink: this.emptyStateMeta.createIssuePath,
          primaryText: __('New issue'),
        };
      }

      if (this.issuesState === IssuesState.Opened) {
        return {
          title: __('There are no open issues'),
          svgPath: this.emptyStateMeta.svgPath,
          description: __('To keep this project going, create a new issue'),
          primaryLink: this.emptyStateMeta.createIssuePath,
          primaryText: __('New issue'),
        };
      } else if (this.issuesState === IssuesState.Closed) {
        return {
          title: __('There are no closed issues'),
          svgPath: this.emptyStateMeta.svgPath,
        };
      }

      return {
        title: __('There are no issues to show'),
        svgPath: this.emptyStateMeta.svgPath,
        description: __(
          'The Issue Tracker is the place to add things that need to be improved or solved in a project. You can register or sign in to create issues for this project.',
        ),
      };
    },
  },
};
</script>

<template>
  <gl-empty-state
    :title="emptyState.title"
    :svg-path="emptyState.svgPath"
    :primary-button-link="emptyState.primaryLink"
    :primary-button-text="emptyState.primaryText"
  >
    <template #description>
      <div v-safe-html="emptyState.description"></div>
    </template>
  </gl-empty-state>
</template>

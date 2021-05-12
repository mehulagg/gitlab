<script>
import { GlButton, GlModalDirective, GlSkeletonLoader } from '@gitlab/ui';
import mergeRequestQueryVariablesMixin from '../../mixins/merge_request_query_variables';
import userPermissionsQuery from '../../queries/permissions.query.graphql';
import conflictsStateQuery from '../../queries/states/conflicts.query.graphql';
import StatusIcon from '../mr_widget_status_icon.vue';

export default {
  name: 'MRWidgetConflicts',
  components: {
    GlSkeletonLoader,
    StatusIcon,
    GlButton,
  },
  directives: {
    GlModalDirective,
  },
  mixins: [mergeRequestQueryVariablesMixin],
  apollo: {
    userPermissions: {
      query: userPermissionsQuery,
      variables() {
        return this.mergeRequestQueryVariables;
      },
      update: (data) => data.project.mergeRequest.userPermissions,
    },
    state: {
      query: conflictsStateQuery,
      variables() {
        return this.mergeRequestQueryVariables;
      },
      update: (data) => data.project.mergeRequest,
    },
  },
  props: {
    /* TODO: This is providing all store and service down when it
      only needs a few props */
    mr: {
      type: Object,
      required: true,
      default: () => ({}),
    },
  },
  data() {
    return {
      userPermissions: {},
      state: {},
    };
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.userPermissions.loading && this.$apollo.queries.state.loading;
    },
    showResolveButton() {
      return (
        this.mr.conflictResolutionPath &&
        this.userPermissions.pushToSourceBranch &&
        !this.state.sourceBranchProtected
      );
    },
  },
};
</script>
<template>
  <div class="mr-widget-body media">
    <status-icon :show-disabled-button="true" status="warning" />

    <div v-if="isLoading" class="gl-ml-4 gl-w-full mr-conflict-loader">
      <gl-skeleton-loader :width="334" :height="30">
        <rect x="0" y="7" width="150" height="16" rx="4" />
        <rect x="158" y="7" width="84" height="16" rx="4" />
        <rect x="250" y="7" width="84" height="16" rx="4" />
      </gl-skeleton-loader>
    </div>
    <div v-else class="media-body space-children gl-display-flex gl-align-items-center">
      <span v-if="state.shouldBeRebased" class="bold">
        {{
          s__(`mrWidget|Fast-forward merge is not possible.
  To merge this request, first rebase locally.`)
        }}
      </span>
      <template v-else>
        <span class="bold">
          {{ s__('mrWidget|There are merge conflicts')
          }}<span v-if="!userPermissions.canMerge">.</span>
          <span v-if="!userPermissions.canMerge">
            {{
              s__(`mrWidget|Resolve these conflicts or ask someone
              with write access to this repository to merge it locally`)
            }}
          </span>
        </span>
        <gl-button
          v-if="showResolveButton"
          :href="mr.conflictResolutionPath"
          data-testid="resolve-conflicts-button"
        >
          {{ s__('mrWidget|Resolve conflicts') }}
        </gl-button>
        <gl-button
          v-if="userPermissions.canMerge"
          v-gl-modal-directive="'modal-merge-info'"
          data-testid="merge-locally-button"
        >
          {{ s__('mrWidget|Merge locally') }}
        </gl-button>
      </template>
    </div>
  </div>
</template>

<script>
import Store from '~/sidebar/stores/sidebar_store';
import { convertToGraphQLId } from '~/graphql_shared/utils';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import SidebarAssigneesWidget from '~/sidebar/components/assignees/sidebar_assignees_widget.vue';
import getIssueParticipants from '~/vue_shared/components/sidebar/queries/get_issue_participants.query.graphql';
import getMrParticipants from '~/vue_shared/components/sidebar/queries/get_mr_participants.query.graphql';
import updateIssueAssigneesMutation from '~/vue_shared/components/sidebar/queries/update_issue_assignees.mutation.graphql';
import updateMrAssigneesMutation from '~/vue_shared/components/sidebar/queries/update_mr_assignees.mutation.graphql';
import AssigneesRealtime from './assignees_realtime.vue';

export default {
  name: 'SidebarAssignees',
  components: {
    AssigneesRealtime,
    SidebarAssigneesWidget,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    mediator: {
      type: Object,
      required: true,
    },
    field: {
      type: String,
      required: true,
    },
    signedIn: {
      type: Boolean,
      required: false,
      default: false,
    },
    issuableType: {
      type: String,
      required: false,
      default: 'issue',
    },
    issuableIid: {
      type: String,
      required: true,
    },
    projectPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      store: new Store(),
      loading: false,
    };
  },
  computed: {
    isIssue() {
      return this.issuableType === 'issue';
    },
    shouldEnableRealtime() {
      // Note: Realtime is only available on issues right now, future support for MR wil be built later.
      return this.glFeatures.realTimeIssueSidebar && this.isIssue;
    },
    participantsQuery() {
      return this.isIssue ? getIssueParticipants : getMrParticipants;
    },
    participantsQueryVariables() {
      return { iid: this.issuableIid, fullPath: this.projectPath };
    },
    updateAssigneesMutation() {
      return this.isIssue ? updateIssueAssigneesMutation : updateMrAssigneesMutation;
    },
    updateAssigneesVariables() {
      return {
        iid: this.issuableIid,
        projectPath: this.projectPath,
      };
    },
  },
  methods: {
    saveAssignees(data) {
      const { nodes: assignees } = this.isIssue
        ? data.issueSetAssignees?.issue?.assignees
        : data.mergeRequestSetAssignees?.mergeRequest?.assignees;
      this.store.setAssigneeData({ assignees });
    },
  },
};
</script>

<template>
  <div>
    <assignees-realtime
      v-if="shouldEnableRealtime"
      :issuable-iid="issuableIid"
      :project-path="projectPath"
      :mediator="mediator"
    />
    <sidebar-assignees-widget
      :loading="store.isFetching.assignees"
      :assignees="store.assignees"
      :participants-query="participantsQuery"
      :participants-query-variables="participantsQueryVariables"
      :update-assignees-mutation="updateAssigneesMutation"
      :update-assignees-variables="updateAssigneesVariables"
      @assigneesUpdated="saveAssignees"
    />
  </div>
</template>

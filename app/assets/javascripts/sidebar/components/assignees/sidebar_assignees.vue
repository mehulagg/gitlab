<script>
import Store from '~/sidebar/stores/sidebar_store';
import { convertToGraphQLId } from '~/graphql_shared/utils';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import SidebarAssigneesWidget from '~/sidebar/components/assignees/sidebar_assignees_widget.vue';
import getIssueParticipants from '~/vue_shared/components/sidebar/queries/getIssueParticipants.query.graphql';
import updateAssigneesMutation from '~/vue_shared/components/sidebar/queries/updateAssignees.mutation.graphql';
import AssigneesRealtime from './assignees_realtime.vue';

export default {
  name: 'SidebarAssignees',
  getIssueParticipants,
  updateAssigneesMutation,
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
    shouldEnableRealtime() {
      // Note: Realtime is only available on issues right now, future support for MR wil be built later.
      return this.glFeatures.realTimeIssueSidebar && this.issuableType === 'issue';
    },
    graphqlIssuableId() {
      /* eslint-disable-next-line @gitlab/require-i18n-strings */
      return convertToGraphQLId('Issue', this.issuableIid);
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
      const { nodes: assignees } = data.issueSetAssignees?.issue?.assignees || [];
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
      :assignees-query="$options.getIssueParticipants"
      :issuable-id="graphqlIssuableId"
      :update-assignees-mutation="$options.updateAssigneesMutation"
      :update-assignees-variables="updateAssigneesVariables"
      @assigneesUpdated="saveAssignees"
    />
  </div>
</template>

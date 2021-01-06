<script>
import { deprecatedCreateFlash as Flash } from '~/flash';
import Store from '~/sidebar/stores/sidebar_store';
import { refreshUserMergeRequestCounts } from '~/commons/nav/user_merge_requests';
import { convertToGraphQLId } from '~/graphql_shared/utils';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import SidebarAssigneesWidget from '~/sidebar/components/assignees/sidebar_assignees_widget.vue';
import getIssueParticipants from '~/vue_shared/components/sidebar/queries/getIssueParticipants.query.graphql';
import updateAssigneesMutation from '~/vue_shared/components/sidebar/queries/updateAssignees.mutation.graphql';
import AssigneesRealtime from './assignees_realtime.vue';
import { __ } from '~/locale';

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
    relativeUrlRoot() {
      return gon.relative_url_root ?? '';
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
  created() {
    this.removeAssignee = this.store.removeAssignee.bind(this.store);
    this.addAssignee = this.store.addAssignee.bind(this.store);
    this.removeAllAssignees = this.store.removeAllAssignees.bind(this.store);
  },
  methods: {
    assignSelf() {
      this.mediator.assignYourself();
      this.saveAssignees();
    },
    saveAssignees() {
      this.loading = true;

      this.mediator
        .saveAssignees(this.field)
        .then(() => {
          this.loading = false;
          this.store.resetChanging();

          refreshUserMergeRequestCounts();
        })
        .catch(() => {
          this.loading = false;
          return new Flash(__('Error occurred when saving assignees'));
        });
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
      :loading="mediator.store.isFetching.assignees"
      :assignees="mediator.store.assignees"
      :assignees-query="$options.getIssueParticipants"
      :issuable-id="graphqlIssuableId"
      :update-assignees-mutation="$options.updateAssigneesMutation"
      :update-assignees-variables="updateAssigneesVariables"
    />
  </div>
</template>

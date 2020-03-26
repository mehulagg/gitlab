<script>
import ActionCable from 'actioncable';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import Flash from '~/flash';
import eventHub from '~/sidebar/event_hub';
import Store from '~/sidebar/stores/sidebar_store';
import query from '~/issuable_sidebar/queries/issueSidebar.query.graphql';
import { refreshUserMergeRequestCounts } from '~/commons/nav/user_merge_requests';
import AssigneeTitle from './assignee_title.vue';
import Assignees from './assignees.vue';
import { __ } from '~/locale';

export default {
  name: 'SidebarAssignees',
  components: {
    AssigneeTitle,
    Assignees,
  },
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
    issuableId: {
      type: Number,
      required: true,
    },
    issueId: {
      type: String,
      required: true,
    },
    projectPath: {
      type: String,
      reauired: true,
    },
  },
  data() {
    return {
      store: new Store(),
      loading: false,
      pollState: false,
    };
  },
  created() {
    this.removeAssignee = this.store.removeAssignee.bind(this.store);
    this.addAssignee = this.store.addAssignee.bind(this.store);
    this.removeAllAssignees = this.store.removeAllAssignees.bind(this.store);

    if (gon.features.projectIssueRealTimePoc) {
      this.$apollo.addSmartQuery('project', {
        query,
        variables() {
          return {
            id: this.issueId,
            fullPath: this.projectPath,
          };
        },
        result({ data, loading }) {
          console.log('updated data', data, data.project.issue.assignees.nodes);
          const nodes = [...data.project.issue.assignees.nodes];

          const assignees = nodes.map(n => ({
            ...n,
            avatar_url: n.avatarUrl,
            id: getIdFromGraphQLId(n.id),
          }));

          this.mediator.store.setAssigneesFromRealtime(assignees);
        },
      });
    }

    // Get events from glDropdown
    eventHub.$on('sidebar.removeAssignee', this.removeAssignee);
    eventHub.$on('sidebar.addAssignee', this.addAssignee);
    eventHub.$on('sidebar.removeAllAssignees', this.removeAllAssignees);
    eventHub.$on('sidebar.saveAssignees', this.saveAssignees);
  },
  mounted() {
    this.initActionCablePolling();
  },
  beforeDestroy() {
    eventHub.$off('sidebar.removeAssignee', this.removeAssignee);
    eventHub.$off('sidebar.addAssignee', this.addAssignee);
    eventHub.$off('sidebar.removeAllAssignees', this.removeAllAssignees);
    eventHub.$off('sidebar.saveAssignees', this.saveAssignees);
  },
  watch: {
    pollState(val) {
      if (this.pollState && gon.features.projectIssueRealTimePoc) {
        this.$apollo.queries.project.refetch();
      }

      this.pollState = false;
    },
  },
  methods: {
    assignSelf() {
      // Notify gl dropdown that we are now assigning to current user
      this.$el.parentElement.dispatchEvent(new Event('assignYourself'));

      this.mediator.assignYourself();
      this.saveAssignees();
    },
    saveAssignees() {
      this.loading = true;

      this.mediator
        .saveAssignees(this.field)
        .then(() => {
          this.loading = false;
          refreshUserMergeRequestCounts();
        })
        .catch(() => {
          this.loading = false;
          return new Flash(__('Error occurred when saving assignees'));
        });
    },
    initActionCablePolling() {
      // TODO: we will need to move this to the sidebar level eventually.
      const cable = ActionCable.createConsumer();
      const self = this;

      cable.subscriptions.create(
        {
          channel: 'IssuesChannel',
          id: this.issuableId,
        },
        {
          received(data) {
            if (data.event === 'updated') {
              self.pollState = true;
            }
          },
        },
      );
    },
  },
};
</script>

<template>
  <div>
    <assignee-title
      :number-of-assignees="store.assignees.length"
      :loading="loading || store.isFetching.assignees"
      :editable="store.editable"
      :show-toggle="!signedIn"
    />
    <assignees
      v-if="!store.isFetching.assignees"
      :root-path="store.rootPath"
      :users="store.assignees"
      :editable="store.editable"
      :issuable-type="issuableType"
      class="value"
      @assign-self="assignSelf"
    />
  </div>
</template>

<script>
import { GlAlert, GlButton, GlDrawer, GlLink, GlTable } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import { joinPaths, visitUrl } from '~/lib/utils/url_utility';
import createIssueMutation from '~/vue_shared/alert_details/graphql/mutations/alert_issue_create.mutation.graphql';
import alertQuery from '~/vue_shared/alert_details/graphql/queries/alert_details.query.graphql';

export default {
  HEADER_HEIGHT: process.env.NODE_ENV === 'development' ? '75px' : '40px',
  components: {
    GlAlert,
    GlButton,
    GlDrawer,
    GlLink,
    GlTable,
  },
  inject: ['projectPath'],
  apollo: {
    alertDetails: {
      query: alertQuery,
      variables() {
        return {
          fullPath: this.projectPath,
          alertId: this.selectedAlert.iid,
        };
      },
      update(data) {
        return data?.project?.alertManagementAlerts?.nodes?.[0] ?? null;
      },
      error(error) {
        this.hasError = true;
        Sentry.captureException(error);
      },
    },
  },
  props: {
    isAlertDrawerOpen: {
      type: Boolean,
      required: false,
      default: false,
    },
    projectId: {
      type: String,
      required: false,
      default: '',
    },
    selectedAlert: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      alertDetails: {},
      hasError: false,
      incidentCreationInProgress: false,
    };
  },
  computed: {
    alertIncidentPath() {
      const issueIid = this.selectedAlert.issue?.iid;
      return issueIid
        ? joinPaths(
            gon.relative_url_root || '/',
            this.projectPath,
            '-',
            'issues/incident',
            issueIid,
          )
        : '';
    },
    hasIssue() {
      return Boolean(this.selectedAlert.issue);
    },
    issueText() {
      return `#${this.selectedAlert.issue.iid}`;
    },
    processedAlertDetails() {
      const filteredKeys = [
        '__typename',
        'assignees',
        'details',
        'iid',
        'issue',
        'notes',
        'severity',
        'status',
        'todos',
      ];

      return Object.entries({ ...this.alertDetails, ...this.alertDetails.details }).reduce(
        (acc, [key, value]) => {
          return filteredKeys.includes(key) ? acc : [...acc, { key, value }];
        },
        [],
      );
    },
  },
  methods: {
    async createIncident() {
      this.incidentCreationInProgress = true;

      try {
        const response = await this.$apollo.mutate({
          mutation: createIssueMutation,
          variables: {
            iid: this.selectedAlert.iid,
            projectPath: this.projectPath,
          },
        });

        const { errors, issue } = response.data;
        if (errors?.length) {
          throw errors;
        } else if (issue) {
          visitUrl(this.getIncidentPath(issue.iid));
        }
      } catch (error) {
        this.handleAlertError(error);
        this.incidentCreationInProgress = false;
      }
    },
    handleAlertError() {
      this.hasError = true;
    },
    getIncidentPath(issueId) {
      return joinPaths(this.projectPath, issueId);
    },
  },
};
</script>
<template>
  <gl-drawer
    ref="editorDrawer"
    :z-index="252"
    :open="isAlertDrawerOpen"
    :header-height="$options.HEADER_HEIGHT"
    @close="$emit('deselect-alert')"
  >
    <template #header>
      <div>
        <h5 class="gl-mb-5">{{ selectedAlert.title }}</h5>
        <div>
          <gl-link v-if="hasIssue" :href="alertIncidentPath" target="_blank">
            {{ issueText }}
          </gl-link>
          <gl-button
            v-else
            :disabled="hasError"
            category="primary"
            variant="confirm"
            @click="createIncident"
            >{{ __('Create incident') }}</gl-button
          >
        </div>
      </div>
    </template>
    <gl-alert v-if="hasError" :dismissable="false">{{ __('There was an error.') }}</gl-alert>
    <gl-table
      class="alert-management-details-table"
      :busy="loading"
      :empty-text="s__('AlertManagement|No alert data to display.')"
      :items="processedAlertDetails"
      :fields="['key', 'value']"
      show-empty
      fixed
    >
      <template #table-busy>
        <gl-loading-icon size="lg" color="dark" class="gl-mt-5" />
      </template>
    </gl-table>
  </gl-drawer>
</template>

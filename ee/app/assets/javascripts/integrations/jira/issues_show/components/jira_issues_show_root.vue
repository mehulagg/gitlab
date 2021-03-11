<script>
import { GlAlert, GlSprintf, GlLink, GlBadge, GlTooltipDirective as GlTooltip } from '@gitlab/ui';
import { fetchIssue } from 'ee/integrations/jira/issues_show/api';
import JiraIssueSidebar from 'ee/integrations/jira/issues_show/components/sidebar/jira_issues_sidebar_root.vue';
import { issueStates, issueStateLabels } from 'ee/integrations/jira/issues_show/constants';
import IssuableShow from '~/issuable_show/components/issuable_show_root.vue';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import Note from './note.vue';

export default {
  name: 'JiraIssuesShow',
  components: {
    GlAlert,
    GlSprintf,
    GlLink,
    GlBadge,
    IssuableShow,
    JiraIssueSidebar,
    Note,
  },
  directives: {
    GlTooltip,
  },
  inject: {
    issuesShowPath: {
      default: '',
    },
  },
  data() {
    return {
      isLoading: true,
      issue: {},
    };
  },
  computed: {
    isIssueOpen() {
      return this.issue.state === issueStates.OPENED;
    },
    statusBadgeClass() {
      return this.isIssueOpen ? 'status-box-open' : 'status-box-issue-closed';
    },
    statusBadgeText() {
      return issueStateLabels[this.issue.state];
    },
    statusIcon() {
      return this.isIssueOpen ? 'issue-open-m' : 'mobile-issue-close';
    },
  },
  async mounted() {
    this.issue = convertObjectPropsToCamelCase(await fetchIssue(this.issuesShowPath), {
      deep: true,
    });
    this.isLoading = false;
  },
  methods: {
    jiraIssueCommentId(id) {
      return `jira_note_${id}`;
    },
  },
};
</script>

<template>
  <div class="gl-mt-5">
    <gl-alert
      variant="info"
      :dismissible="false"
      :title="s__('JiraService|This issue is synchronized with Jira')"
      class="gl-mb-2"
    >
      <gl-sprintf
        :message="
          s__(
            `JiraService|Not all data may be displayed here. To view more details or make changes to this issue, go to %{linkStart}Jira%{linkEnd}.`,
          )
        "
      >
        <template #link="{ content }">
          <gl-link :href="issue.webUrl" target="_blank">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
    </gl-alert>

    <issuable-show
      v-if="!isLoading"
      :issuable="issue"
      :enable-edit="false"
      :status-badge-class="statusBadgeClass"
      :status-icon="statusIcon"
    >
      <template #status-badge>{{ statusBadgeText }}</template>

      <template #right-sidebar-items="{ sidebarExpanded }">
        <jira-issue-sidebar :sidebar-expanded="sidebarExpanded" :issue="issue" />
      </template>

      <template #discussion>
        <note
          v-for="comment in issue.comments"
          :id="jiraIssueCommentId(comment.id)"
          :key="comment.id"
          :author-avatar-url="comment.author.avatarUrl"
          :author-web-url="comment.author.webUrl"
          :author-name="comment.author.name"
          :author-username="comment.author.username"
          :note-body-html="comment.bodyHtml"
          :note-created-at="comment.createdAt"
        >
          <template #badges>
            <gl-badge v-gl-tooltip="{ title: __('This is a Jira user.') }">
              {{ __('Jira user') }}
            </gl-badge>
          </template>
        </note>
      </template>
    </issuable-show>
  </div>
</template>

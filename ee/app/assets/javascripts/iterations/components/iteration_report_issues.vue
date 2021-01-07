<script>
import {
  GlAlert,
  GlLoadingIcon,
  GlAvatar,
  GlLink,
  GlPagination,
  GlTable,
  GlTooltipDirective,
} from '@gitlab/ui';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { __, sprintf } from '~/locale';
import { Namespace } from '../constants';
import iterationIssuesQuery from '../queries/iteration_issues.query.graphql';
import iterationIssuesWithLabelFilterQuery from '../queries/iteration_issues_with_label_filter.query.graphql';

const pageSize = 20;

const states = {
  opened: 'opened',
  closed: 'closed',
};

export default {
  fields: [
    {
      key: 'title',
      label: __('Title'),
      class: 'gl-bg-transparent! gl-border-b-1',
    },
    {
      key: 'status',
      label: __('Status'),
      class: 'gl-bg-transparent! gl-text-truncate',
      thClass: 'gl-w-eighth',
    },
    {
      key: 'assignees',
      label: __('Assignees'),
      class: 'gl-bg-transparent! gl-text-right',
      thClass: 'gl-w-eighth',
    },
  ],
  components: {
    GlAlert,
    GlAvatar,
    GlLink,
    GlLoadingIcon,
    GlPagination,
    GlTable,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    fullPath: {
      type: String,
      required: true,
    },
    iterationId: {
      type: String,
      required: true,
    },
    labelName: {
      type: String,
      required: false,
      default: '',
    },
    namespaceType: {
      type: String,
      required: false,
      default: Namespace.Group,
      validator: (value) => Object.values(Namespace).includes(value),
    },
  },
  data() {
    return {
      issues: {
        list: [],
        pageInfo: {
          hasNextPage: true,
          hasPreviousPage: false,
        },
      },
      error: '',
      pagination: {
        currentPage: 1,
      },
    };
  },
  apollo: {
    issues: {
      query() {
        return this.labelName ? iterationIssuesWithLabelFilterQuery : iterationIssuesQuery;
      },
      variables() {
        return this.queryVariables;
      },
      update(data) {
        const { nodes: issues = [], count, pageInfo = {} } = data[this.namespaceType]?.issues || {};

        const list = issues.map((issue) => ({
          ...issue,
          labels: issue?.labels?.nodes || [],
          assignees: issue?.assignees?.nodes || [],
        }));

        return {
          pageInfo,
          list,
          count,
        };
      },
      result({ data }) {
        this.$emit('issueCount', data[this.namespaceType]?.issues?.count);
      },
      error() {
        this.error = __('Error loading issues');
      },
    },
  },
  computed: {
    queryVariables() {
      const vars = {
        fullPath: this.fullPath,
        id: getIdFromGraphQLId(this.iterationId),
        isGroup: this.namespaceType === Namespace.Group,
        labelName: this.labelName,
      };

      if (this.pagination.beforeCursor) {
        vars.beforeCursor = this.pagination.beforeCursor;
        vars.lastPageSize = pageSize;
      } else {
        vars.afterCursor = this.pagination.afterCursor;
        vars.firstPageSize = pageSize;
      }

      return vars;
    },
    prevPage() {
      return Number(this.issues.pageInfo.hasPreviousPage);
    },
    nextPage() {
      return Number(this.issues.pageInfo.hasNextPage);
    },
  },
  methods: {
    issueState(state, assigneeCount) {
      if (state === states.opened && assigneeCount === 0) {
        return __('Open');
      }
      if (state === states.opened && assigneeCount > 0) {
        return __('In progress');
      }
      return __('Closed');
    },
    tooltipText(assignee) {
      return sprintf(__('Assigned to %{assigneeName}'), {
        assigneeName: assignee.name,
      });
    },
    handlePageChange(page) {
      const { startCursor, endCursor } = this.issues.pageInfo;

      if (page > this.pagination.currentPage) {
        this.pagination = {
          afterCursor: endCursor,
          currentPage: page,
        };
      } else {
        this.pagination = {
          beforeCursor: startCursor,
          currentPage: page,
        };
      }
    },
  },
};
</script>

<template>
  <div>
    <gl-alert v-if="error" variant="danger" @dismiss="error = ''">{{ error }}</gl-alert>

    <gl-loading-icon v-show="$apollo.queries.issues.loading" class="gl-my-9" size="md" />

    <gl-table
      v-show="!$apollo.queries.issues.loading"
      :items="issues.list"
      :fields="$options.fields"
      :empty-text="__('No issues found')"
      :show-empty="true"
      fixed
      stacked="sm"
      data-qa-selector="iteration_issues_container"
    >
      <template #cell(title)="{ item: { iid, title, webUrl } }">
        <div class="gl-text-truncate">
          <gl-link
            class="gl-text-gray-900 gl-font-weight-bold"
            :href="webUrl"
            data-qa-selector="iteration_issue_link"
            :data-qa-issue-title="title"
            >{{ title }}
          </gl-link>
          <!-- TODO: add references.relative (project name) -->
          <!-- Depends on https://gitlab.com/gitlab-org/gitlab/-/issues/222763 -->
          <div class="gl-text-secondary">#{{ iid }}</div>
        </div>
      </template>

      <template #cell(status)="{ item: { state, assignees = [] } }">
        <span class="gl-w-6 gl-flex-shrink-0">{{ issueState(state, assignees.length) }}</span>
      </template>

      <template #cell(assignees)="{ item: { assignees } }">
        <span class="assignee-icon gl-w-6">
          <span
            v-for="assignee in assignees"
            :key="assignee.username"
            v-gl-tooltip="tooltipText(assignee)"
          >
            <gl-avatar :src="assignee.avatarUrl" :size="16" />
          </span>
        </span>
      </template>
    </gl-table>
    <div class="mt-3">
      <gl-pagination
        :value="pagination.currentPage"
        :prev-page="prevPage"
        :next-page="nextPage"
        align="center"
        class="gl-pagination gl-mt-3"
        @input="handlePageChange"
      />
    </div>
  </div>
</template>

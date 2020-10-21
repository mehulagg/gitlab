<script>
import {
  GlAlert,
  GlAvatar,
  GlBadge,
  GlLink,
  GlLoadingIcon,
  GlPagination,
  GlTab,
  GlTabs,
  GlTable,
  GlTooltipDirective,
} from '@gitlab/ui';
import { __, sprintf } from '~/locale';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import query from '../queries/iteration_issues.query.graphql';
import { Namespace } from '../constants';

const states = {
  opened: 'opened',
  closed: 'closed',
};

const pageSize = 20;

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
    GlBadge,
    GlLink,
    GlLoadingIcon,
    GlPagination,
    GlTab,
    GlTabs,
    GlTable,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  apollo: {
    issues: {
      query,
      variables() {
        return this.queryVariables;
      },
      update(data) {
        const { nodes: issues = [], count, pageInfo = {} } = data[this.namespaceType]?.issues || {};

        const list = issues.map(issue => ({
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
      error() {
        this.error = __('Error loading issues');
      },
    },
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
    namespaceType: {
      type: String,
      required: false,
      default: Namespace.Group,
      validator: value => Object.values(Namespace).includes(value),
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
  computed: {
    queryVariables() {
      const vars = {
        fullPath: this.fullPath,
        id: getIdFromGraphQLId(this.iterationId),
        isGroup: this.namespaceType === Namespace.Group,
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
    tooltipText(assignee) {
      return sprintf(__('Assigned to %{assigneeName}'), {
        assigneeName: assignee.name,
      });
    },
    issueState(state, assigneeCount) {
      if (state === states.opened && assigneeCount === 0) {
        return __('Open');
      }
      if (state === states.opened && assigneeCount > 0) {
        return __('In progress');
      }
      return __('Closed');
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
  <gl-tabs>
    <gl-alert v-if="error" variant="danger" @dismiss="error = ''">
      {{ error }}
    </gl-alert>
    <gl-tab title="Issues">
      <template #title>
        <span>{{ __('Issues') }}</span
        ><gl-badge class="ml-2" variant="neutral">{{ issues.count }}</gl-badge>
      </template>

      <gl-loading-icon v-if="$apollo.queries.issues.loading" class="gl-my-9" size="md" />
      <gl-table
        v-else
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
              >{{ title }}</gl-link
            >
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
    </gl-tab>
  </gl-tabs>
</template>

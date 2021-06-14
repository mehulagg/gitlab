import { DEFAULT_PAGE_SIZE } from '~/issuable_list/constants';
import axios from '~/lib/utils/axios_utils';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import { __ } from '~/locale';

const transformJiraIssueAssignees = (jiraIssue) => {
  return jiraIssue.assignees.map((assignee) => ({
    __typename: 'UserCore',
    ...assignee,
  }));
};

const transformJiraIssueAuthor = (jiraIssue, authorId) => {
  return {
    __typename: 'UserCore',
    ...jiraIssue.author,
    id: authorId,
  };
};

const transformJiraIssueLabels = (jiraIssue) => {
  return jiraIssue.labels.map((label) => ({
    __typename: 'Label', // eslint-disable-line @gitlab/require-i18n-strings
    ...label,
  }));
};

export const transformJiraIssuesREST = (response) => {
  const { headers, data: jiraIssues } = response;

  return {
    __typename: 'JiraIssues',
    errors: [],
    pageInfo: {
      __typename: 'JiraIssuesPageInfo',
      page: parseInt(headers['x-page'], 10),
      total: parseInt(headers['x-total'], 10),
    },
    nodes: jiraIssues.map((rawIssue, index) => {
      const jiraIssue = convertObjectPropsToCamelCase(rawIssue, { deep: true });
      return {
        __typename: 'JiraIssue',
        ...jiraIssue,
        // JIRA issues don't have ID so we extract
        // an ID equivalent from references.relative
        id: parseInt(rawIssue.references.relative.split('-').pop(), 10),
        author: transformJiraIssueAuthor(jiraIssue, index),
        labels: transformJiraIssueLabels(jiraIssue),
        assignees: transformJiraIssueAssignees(jiraIssue),
      };
    }),
  };
};

export default function jiraIssuesResolver(
  _,
  { issuesFetchPath, search, page, state, sort, labels },
) {
  return axios
    .get(issuesFetchPath, {
      params: {
        with_labels_details: true,
        per_page: DEFAULT_PAGE_SIZE,
        page,
        state,
        sort,
        labels,
        search,
      },
    })
    .then((res) => {
      return transformJiraIssuesREST(res);
    })
    .catch((error) => {
      return {
        __typename: 'JiraIssues',
        errors: error?.response?.data?.errors || [__('An error occurred while loading issues')],
        pageInfo: {
          total: 0,
          page: 1,
        },
        nodes: [],
      };
    });
}

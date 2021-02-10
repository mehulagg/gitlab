import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

/**
 *
 * @param {*} rawJiraIssue
 */
export const transformJiraIssue = (rawJiraIssue) => {
  const jiraIssue = {
    ...convertObjectPropsToCamelCase(rawJiraIssue, { deep: true }),
    id: parseInt(rawJiraIssue.references.relative.split('-').pop(), 10),
  };

  return jiraIssue;
};

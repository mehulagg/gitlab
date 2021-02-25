import { IssuableType } from '~/issue_show/constants';
import issueConfidentialQuery from '~/sidebar/queries/issue_confidential.query.graphql';
import updateIssueConfidentialMutation from '~/sidebar/queries/update_issue_confidential.mutation.graphql';
import getIssueParticipants from '~/vue_shared/components/sidebar/queries/get_issue_participants.query.graphql';
import getMergeRequestParticipants from '~/vue_shared/components/sidebar/queries/get_mr_participants.query.graphql';
import updateAssigneesMutation from '~/vue_shared/components/sidebar/queries/update_issue_assignees.mutation.graphql';
import updateMergeRequestParticipantsMutation from '~/vue_shared/components/sidebar/queries/update_mr_assignees.mutation.graphql';

export const assigneesQueries = {
  [IssuableType.Issue]: {
    query: getIssueParticipants,
    mutation: updateAssigneesMutation,
  },
  [IssuableType.MergeRequest]: {
    query: getMergeRequestParticipants,
    mutation: updateMergeRequestParticipantsMutation,
  },
};

export const confidentialityQueries = {
  [IssuableType.Issue]: {
    query: issueConfidentialQuery,
    mutation: updateIssueConfidentialMutation,
  },
};

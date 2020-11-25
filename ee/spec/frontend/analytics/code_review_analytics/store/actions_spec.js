import * as actions from 'ee/analytics/code_review_analytics/store/actions';
import testAction from 'helpers/vuex_action_helper';

describe('Code review analytics actions', () => {
  let state;

  describe('setFilters', () => {
    const selectedMilestone = { value: 'my milestone', operator: '=' };
    const selectedLabels = [
      { value: 'first label', operator: '=' },
      { value: 'second label', operator: '!=' },
    ];

    it('commits the SET_FILTERS mutation', () => {
      testAction(
        actions.setFilters,
        { labelNames: selectedLabels, milestoneTitle: selectedMilestone },
        state,
        [],
        [
          { type: 'mergeRequests/setPage', payload: 1 },
          { type: 'mergeRequests/fetchMergeRequests', payload: null },
        ],
      );
    });
  });
});

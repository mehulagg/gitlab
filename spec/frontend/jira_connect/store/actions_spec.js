import testAction from 'helpers/vuex_action_helper';

import createState from '~/integrations/edit/store/state';
import * as actions from '~/jira_connect/store/actions';
import * as types from '~/jira_connect/store/mutation_types';

describe('JiraConnect store actions', () => {
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe('setErrorMessage', () => {
    it('should commit errorMessage mutation', () => {
      const mockError = 'error message';

      return testAction(actions.setErrorMessage, mockError, state, [
        { type: types.SET_ERROR_MESSAGE, payload: mockError },
      ]);
    });
  });
});

import configureMediator, {
  updateIssueActionsMap,
} from 'ee/vue_shared/security_reports/store/mediator';
import * as types from 'ee/vue_shared/security_reports/store/mutation_types';

const mockedStore = {
  dispatch: jest.fn(),
};

mockedStore.subscribe = (callback) => {
  mockedStore.commit = callback;
};

describe('security reports mediator', () => {
  beforeEach(() => {
    configureMediator(mockedStore);
  });

  describe(types.RECEIVE_DISMISS_VULNERABILITY_SUCCESS, () => {
    const type = types.RECEIVE_DISMISS_VULNERABILITY_SUCCESS;

    it.each(Object.entries(updateIssueActionsMap).map((entry) => entry.reverse()))(
      `should trigger %s on when a %s is updated`,
      (action, category) => {
        const payload = { category };
        mockedStore.commit({ type, payload });

        expect(mockedStore.dispatch).toHaveBeenCalledWith(action, payload);
      },
    );
  });
});

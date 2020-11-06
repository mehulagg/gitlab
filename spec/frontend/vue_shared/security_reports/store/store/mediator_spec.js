import * as types from 'ee/vue_shared/security_reports/store/mutation_types';
import configureMediator from 'ee/vue_shared/security_reports/store/mediator';

const mockedStore = {
  dispatch: jest.fn(),
};

mockedStore.subscribe = callback => {
  mockedStore.commit = callback;
};

describe('security reports mediator', () => {
  beforeEach(() => {
    configureMediator(mockedStore);
  });

  describe(types.RECEIVE_DISMISS_VULNERABILITY_SUCCESS, () => {
    const type = types.RECEIVE_DISMISS_VULNERABILITY_SUCCESS;

    it.each`
      action                             | category
      ${'sast/updateVulnerability'}      | ${'sast'}
      ${'updateDastIssue'}               | ${'dast'}
      ${'updateDependencyScanningIssue'} | ${'dependency_scanning'}
      ${'updateContainerScanningIssue'}  | ${'container_scanning'}
    `(`should trigger $action on when a $category is updated`, data => {
      const { action, category } = data;
      const payload = { category };
      mockedStore.commit({ type, payload });

      expect(mockedStore.dispatch).toHaveBeenCalledWith(action, payload);
    });
  });
});

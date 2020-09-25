import commitState from '~/ide/stores/modules/commit/state';
import mutations from '~/ide/stores/modules/commit/mutations';
import * as types from '~/ide/stores/modules/commit/mutation_types';

describe('IDE commit module mutations', () => {
  let state;

  beforeEach(() => {
    state = commitState();
  });

  describe('UPDATE_COMMIT_MESSAGE', () => {
    it('updates commitMessage', () => {
      mutations.UPDATE_COMMIT_MESSAGE(state, 'testing');

      expect(state.commitMessage).toBe('testing');
    });
  });

  describe('UPDATE_COMMIT_ACTION', () => {
    it('updates commitAction', () => {
      mutations.UPDATE_COMMIT_ACTION(state, { commitAction: 'testing' });

      expect(state.commitAction).toBe('testing');
    });
  });

  describe('UPDATE_NEW_BRANCH_NAME', () => {
    it('updates newBranchName', () => {
      mutations.UPDATE_NEW_BRANCH_NAME(state, { branchName: 'testing' });

      expect(state.newBranchName).toBe('testing');
    });

    it('adds numeric suffix to branch name if addSuffix=true', () => {
      mutations.UPDATE_NEW_BRANCH_NAME(state, { branchName: 'testing', addSuffix: true });

      expect(state.newBranchName).toBe('testing-1');
    });

    it('picks the branch name from state if branchName is not passed', () => {
      state.newBranchName = 'master';
      mutations.UPDATE_NEW_BRANCH_NAME(state, { addSuffix: true });

      expect(state.newBranchName).toBe('master-1');
    });

    it('picks placeholder branch name if branch name is not passed and does not exist in state', () => {
      state.placeholderBranchName = 'root-master-patch-25322';

      expect(state.newBranchName).toBe('');

      mutations.UPDATE_NEW_BRANCH_NAME(state, {});

      expect(state.newBranchName).toBe('root-master-patch-25322');

      mutations.UPDATE_NEW_BRANCH_NAME(state, { addSuffix: true });

      expect(state.newBranchName).toBe('root-master-patch-25323');
    });
  });

  describe('UPDATE_LOADING', () => {
    it('updates submitCommitLoading', () => {
      mutations.UPDATE_LOADING(state, true);

      expect(state.submitCommitLoading).toBeTruthy();
    });
  });

  describe('TOGGLE_SHOULD_CREATE_MR', () => {
    it('changes shouldCreateMR to true when initial state is false', () => {
      state.shouldCreateMR = false;
      mutations.TOGGLE_SHOULD_CREATE_MR(state);

      expect(state.shouldCreateMR).toBe(true);
    });

    it('changes shouldCreateMR to false when initial state is true', () => {
      state.shouldCreateMR = true;
      mutations.TOGGLE_SHOULD_CREATE_MR(state);

      expect(state.shouldCreateMR).toBe(false);
    });

    it('sets shouldCreateMR to given value when passed in', () => {
      state.shouldCreateMR = false;
      mutations.TOGGLE_SHOULD_CREATE_MR(state, false);

      expect(state.shouldCreateMR).toBe(false);
    });
  });

  describe(types.CLEAR_ERROR, () => {
    it('should clear commitError', () => {
      state.commitError = {};

      mutations[types.CLEAR_ERROR](state);

      expect(state.commitError).toBeNull();
    });
  });

  describe(types.SET_ERROR, () => {
    it('should set commitError', () => {
      const error = { title: 'foo' };

      mutations[types.SET_ERROR](state, error);

      expect(state.commitError).toBe(error);
    });
  });
});

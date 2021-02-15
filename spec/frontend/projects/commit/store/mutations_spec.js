import * as types from '~/projects/commit/store/mutation_types';
import mutations from '~/projects/commit/store/mutations';

describe('Commit form modal mutations', () => {
  let stateCopy;

  describe('REQUEST_BRANCHES', () => {
    it('should set isFetching to true', () => {
      stateCopy = { isFetching: false };

      mutations[types.REQUEST_BRANCHES](stateCopy);

      expect(stateCopy.isFetching).toBe(true);
    });
  });

  describe('RECEIVE_BRANCHES_SUCCESS', () => {
    it('should set branches', () => {
      stateCopy = { branch: '_existing_branch_', isFetching: true };

      mutations[types.RECEIVE_BRANCHES_SUCCESS](stateCopy, ['_branch_1_', '_branch_2_']);

      expect(stateCopy.branches).toEqual(['_existing_branch_', '_branch_1_', '_branch_2_']);
      expect(stateCopy.isFetching).toEqual(false);
    });
  });

  describe('CLEAR_MODAL', () => {
    it('should clear modal state ', () => {
      stateCopy = { branch: '_master_', defaultBranch: '_default_branch_' };

      mutations[types.CLEAR_MODAL](stateCopy);

      expect(stateCopy.branch).toEqual('_default_branch_');
    });
  });

  describe('SET_BRANCH', () => {
    it('should set branch', () => {
      stateCopy = { branch: '_master_' };

      mutations[types.SET_BRANCH](stateCopy, '_changed_branch_');

      expect(stateCopy.branch).toBe('_changed_branch_');
    });
  });

  describe('SET_SELECTED_BRANCH', () => {
    it('should set selectedBranch', () => {
      stateCopy = { selectedBranch: '_master_' };

      mutations[types.SET_SELECTED_BRANCH](stateCopy, '_changed_branch_');

      expect(stateCopy.selectedBranch).toBe('_changed_branch_');
    });
  });
});

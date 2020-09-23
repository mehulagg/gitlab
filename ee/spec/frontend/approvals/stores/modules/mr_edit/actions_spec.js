import testAction from 'helpers/vuex_action_helper';
import * as types from 'ee/approvals/stores/modules/mr_edit/mutation_types';
import * as actions from 'ee/approvals/stores/modules/mr_edit/actions';

describe('Approval MR edit module actions', () => {
  describe('setTargetBranch', () => {
    it('commits SET_TARGET_BRANCH', done => {
      testAction(
        actions.setTargetBranch,
        'master',
        {},
        [{ type: types.SET_TARGET_BRANCH, payload: 'master' }],
        [],
        done,
      );
    });
  });

  describe('undoRulesChange', () => {
    it('commits UNDO_RULES', done => {
      testAction(actions.undoRulesChange, null, {}, [{ type: types.UNDO_RULES }], [], done);
    });
  });
});

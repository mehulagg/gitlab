import testAction from 'helpers/vuex_action_helper';
import createState from 'ee/vue_shared/security_reports/store/modules/sast/state';
import * as types from 'ee/vue_shared/security_reports/store/modules/sast/mutation_types';
import * as actions from 'ee/vue_shared/security_reports/store/modules/sast/actions';

const issue = {};
let state;

// See also the corresponding CE specs in
// spec/frontend/vue_shared/security_reports/store/modules/sast/actions_spec.js
describe('EE sast report actions', () => {
  beforeEach(() => {
    state = createState();
  });

  describe('updateVulnerability', () => {
    it(`should commit ${types.UPDATE_VULNERABILITY} with the correct response`, done => {
      testAction(
        actions.updateVulnerability,
        issue,
        state,
        [
          {
            type: types.UPDATE_VULNERABILITY,
            payload: issue,
          },
        ],
        [],
        done,
      );
    });
  });
});

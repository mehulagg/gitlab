import MockAdapter from 'axios-mock-adapter';
import * as actions from 'ee/approvals/stores/modules/group_settings/actions';
import * as types from 'ee/approvals/stores/modules/group_settings/mutation_types';
import getInitialState from 'ee/approvals/stores/modules/group_settings/state';
import testAction from 'helpers/vuex_action_helper';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import httpStatus from '~/lib/utils/http_status';

jest.mock('~/flash');

describe('EE approvals group settings module actions', () => {
  let state;
  let mock;

  const approvalSettingsPath = 'groups/22/merge_request_approval_setting';

  beforeEach(() => {
    state = getInitialState();
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    createFlash.mockClear();
    mock.restore();
  });

  describe('fetchSettings', () => {
    describe('on success', () => {
      it('dispatches the request and updates payload', () => {
        const data = { allow_author_approval: true };
        mock.onGet(approvalSettingsPath).replyOnce(httpStatus.OK, data);

        return testAction(
          actions.fetchSettings,
          approvalSettingsPath,
          state,
          [
            { type: types.REQUEST_SETTINGS },
            { type: types.RECEIVE_SETTINGS_SUCCESS, payload: data },
          ],
          [],
        );
      });
    });

    describe('on error', () => {
      it('dispatches the request, updates payload and sets error message', () => {
        const data = { message: 'Internal Server Error' };
        mock.onGet(approvalSettingsPath).replyOnce(httpStatus.INTERNAL_SERVER_ERROR, data);

        return testAction(
          actions.fetchSettings,
          approvalSettingsPath,
          state,
          [{ type: types.REQUEST_SETTINGS }, { type: types.RECEIVE_SETTINGS_ERROR }],
          [],
        ).then(() => {
          expect(createFlash).toHaveBeenCalledWith({
            message: 'There was an error loading merge request approval settings.',
            captureError: true,
            error: 'Internal Server Error',
          });
        });
      });
    });
  });

  describe('updateSettings', () => {
    beforeEach(() => {
      state = {
        settings: {
          preventAuthorApproval: false,
          preventCommittersApproval: false,
          preventMrApprovalRuleEdit: false,
          requireUserPassword: false,
          removeApprovalsOnPush: false,
        },
      };
    });

    describe('on success', () => {
      it('dispatches the request and updates payload', () => {
        const data = {
          allow_author_approval: true,
          allow_committer_approval: true,
          allow_overrides_to_approver_list_per_merge_request: true,
          require_password_to_approve: true,
          retain_approvals_on_push: true,
        };
        mock.onPut(approvalSettingsPath).replyOnce(httpStatus.OK, data);

        return testAction(
          actions.updateSettings,
          approvalSettingsPath,
          state,
          [
            { type: types.REQUEST_UPDATE_SETTINGS },
            { type: types.UPDATE_SETTINGS_SUCCESS, payload: data },
          ],
          [],
        ).then(() => {
          expect(createFlash).toHaveBeenCalledWith({
            message: 'Merge request approval settings have been updated.',
            type: 'notice',
          });
        });
      });
    });

    describe('on error', () => {
      it('dispatches the request, updates payload and sets error message', () => {
        const data = { message: 'Internal Server Error' };
        mock.onPut(approvalSettingsPath).replyOnce(httpStatus.INTERNAL_SERVER_ERROR, data);

        return testAction(
          actions.updateSettings,
          approvalSettingsPath,
          state,
          [{ type: types.REQUEST_UPDATE_SETTINGS }, { type: types.UPDATE_SETTINGS_ERROR }],
          [],
        ).then(() => {
          expect(createFlash).toHaveBeenCalledWith({
            message: 'There was an error updating merge request approval settings.',
            captureError: true,
            error: 'Internal Server Error',
          });
        });
      });
    });
  });

  describe.each`
    action                            | type                                       | prop
    ${'setPreventAuthorApproval'}     | ${types.SET_PREVENT_AUTHOR_APPROVAL}       | ${'preventAuthorApproval'}
    ${'setPreventCommittersApproval'} | ${types.SET_PREVENT_COMMITTERS_APPROVAL}   | ${'preventCommittersApproval'}
    ${'setPreventMrApprovalRuleEdit'} | ${types.SET_PREVENT_MR_APPROVAL_RULE_EDIT} | ${'preventMrApprovalRuleEdit'}
    ${'setRemoveApprovalsOnPush'}     | ${types.SET_REMOVE_APPROVALS_ON_PUSH}      | ${'removeApprovalsOnPush'}
    ${'setRequireUserPassword'}       | ${types.SET_REQUIRE_USER_PASSWORD}         | ${'requireUserPassword'}
  `('$action', ({ action, type, prop }) => {
    it(`commits ${type}`, () => {
      const payload = { [prop]: true };

      return testAction(actions[action], payload, state, [{ type, payload: true }], []);
    });
  });
});

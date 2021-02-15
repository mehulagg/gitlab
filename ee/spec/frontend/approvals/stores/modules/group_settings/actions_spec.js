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
          [
            { type: types.REQUEST_SETTINGS },
            { type: types.RECEIVE_SETTINGS_ERROR, payload: data.message },
          ],
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

  describe('updatePreventAuthorApproval', () => {
    it('updates payload', () => {
      const value = false;

      return testAction(
        actions.updatePreventAuthorApproval,
        value,
        state,
        [{ type: types.UPDATE_PREVENT_AUTHOR_APPROVAL, payload: value }],
        [],
      );
    });
  });
});

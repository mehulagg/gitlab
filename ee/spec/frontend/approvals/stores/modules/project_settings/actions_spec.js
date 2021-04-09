import MockAdapter from 'axios-mock-adapter';
import {
  mapApprovalRuleRequest,
  mapApprovalSettingsResponse,
  mapExternalApprovalResponse,
} from 'ee/approvals/mappers';
import * as types from 'ee/approvals/stores/modules/base/mutation_types';
import * as actions from 'ee/approvals/stores/modules/project_settings/actions';
import { joinRuleResponses } from 'ee/approvals/utils';
import testAction from 'helpers/vuex_action_helper';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import httpStatus from '~/lib/utils/http_status';

jest.mock('~/flash');

const TEST_PROJECT_ID = 9;
const TEST_RULE_ID = 7;
const TEST_RULE_REQUEST = {
  name: 'Lorem',
  approvalsRequired: 1,
  groups: [7],
  users: [8, 9],
};
const TEST_EXTERNAL_RULE_REQUEST = {
  name: 'Lorem',
  protected_branch_ids: [],
  external_url: 'https://www.gitlab.com',
};
const TEST_RULE_RESPONSE = {
  id: 7,
  name: 'Ipsum',
  approvals_required: 2,
  approvers: [{ id: 7 }, { id: 8 }, { id: 9 }],
  groups: [{ id: 4 }],
  users: [{ id: 7 }, { id: 8 }],
};
const TEST_SETTINGS_PATH = 'projects/9/approval_settings';
const TEST_RULES_PATH = 'projects/9/approval_settings/rules';
const TEST_EXTERNAL_RULES_PATH = 'projects/9/external_approval_rules';

describe('EE approvals project settings module actions', () => {
  let state;
  let mock;
  let originalGon;

  beforeEach(() => {
    originalGon = { ...window.gon };
    window.gon = { features: { ffComplianceApprovalGates: true } };
    state = {
      settings: {
        externalApprovalRulesPath: TEST_EXTERNAL_RULES_PATH,
        projectId: TEST_PROJECT_ID,
        settingsPath: TEST_SETTINGS_PATH,
        rulesPath: TEST_RULES_PATH,
      },
    };
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    mock.restore();
    window.gon = originalGon;
  });

  describe('requestRules', () => {
    it('sets loading', () => {
      return testAction(
        actions.requestRules,
        null,
        {},
        [{ type: types.SET_LOADING, payload: true }],
        [],
      );
    });
  });

  describe('receiveRulesSuccess', () => {
    it('sets rules', () => {
      const settings = { rules: [{ id: 1 }] };

      return testAction(
        actions.receiveRulesSuccess,
        settings,
        {},
        [
          { type: types.SET_APPROVAL_SETTINGS, payload: settings },
          { type: types.SET_LOADING, payload: false },
        ],
        [],
      );
    });
  });

  describe('receiveRulesError', () => {
    it('creates a flash', () => {
      expect(createFlash).not.toHaveBeenCalled();

      actions.receiveRulesError();

      expect(createFlash).toHaveBeenCalledTimes(1);
      expect(createFlash).toHaveBeenCalledWith({
        message: expect.stringMatching('error occurred'),
      });
    });
  });

  describe('fetchRules', () => {
    const testFetchRuleAction = (payload, history) => {
      return testAction(
        actions.fetchRules,
        null,
        state,
        [],
        [{ type: 'requestRules' }, { type: 'receiveRulesSuccess', payload }],
        () => {
          expect(mock.history.get.map((x) => x.url)).toEqual(history);
        },
      );
    };

    it('dispatches request/receive', () => {
      const data = { rules: [TEST_RULE_RESPONSE] };
      mock.onGet(TEST_SETTINGS_PATH).replyOnce(httpStatus.OK, data);

      const externalRuleData = [TEST_RULE_RESPONSE];
      mock.onGet(TEST_EXTERNAL_RULES_PATH).replyOnce(httpStatus.OK, externalRuleData);

      return testFetchRuleAction(
        joinRuleResponses([
          mapApprovalSettingsResponse(data),
          mapExternalApprovalResponse(externalRuleData),
        ]),
        [TEST_SETTINGS_PATH, TEST_EXTERNAL_RULES_PATH],
      );
    });

    it('dispatches request/receive on error', () => {
      mock.onGet(TEST_SETTINGS_PATH).replyOnce(httpStatus.INTERNAL_SERVER_ERROR);

      return testAction(
        actions.fetchRules,
        null,
        state,
        [],
        [{ type: 'requestRules' }, { type: 'receiveRulesError' }],
      );
    });

    describe('when the ffComplianceApprovalGates feature flag is disabled', () => {
      beforeEach(() => {
        window.gon = { features: { ffComplianceApprovalGates: false } };
      });

      it('dispatches request/receive for a single request', () => {
        const data = { rules: [TEST_RULE_RESPONSE] };
        mock.onGet(TEST_SETTINGS_PATH).replyOnce(httpStatus.OK, data);

        return testFetchRuleAction(joinRuleResponses([mapApprovalSettingsResponse(data)]), [
          TEST_SETTINGS_PATH,
        ]);
      });
    });
  });

  describe('postRuleSuccess', () => {
    it('closes modal and fetches', () => {
      return testAction(
        actions.postRuleSuccess,
        null,
        {},
        [],
        [{ type: 'createModal/close' }, { type: 'fetchRules' }],
      );
    });
  });

  describe('POST', () => {
    it.each`
      action                        | path                        | request
      ${'postRule'}                 | ${TEST_RULES_PATH}          | ${TEST_RULE_REQUEST}
      ${'postExternalApprovalRule'} | ${TEST_EXTERNAL_RULES_PATH} | ${TEST_EXTERNAL_RULE_REQUEST}
    `('dispatches success on success for $action', ({ action, path, request }) => {
      mock.onPost(path).replyOnce(httpStatus.OK);

      return testAction(actions[action], request, state, [], [{ type: 'postRuleSuccess' }], () => {
        expect(mock.history.post).toEqual([
          expect.objectContaining({
            url: path,
            data: JSON.stringify(mapApprovalRuleRequest(request)),
          }),
        ]);
      });
    });
  });

  describe('PUT', () => {
    it.each`
      action                       | path                        | request
      ${'putRule'}                 | ${TEST_RULES_PATH}          | ${TEST_RULE_REQUEST}
      ${'putExternalApprovalRule'} | ${TEST_EXTERNAL_RULES_PATH} | ${TEST_EXTERNAL_RULE_REQUEST}
    `('dispatches success on success for $action', ({ action, path, request }) => {
      mock.onPut(`${path}/${TEST_RULE_ID}`).replyOnce(httpStatus.OK);

      return testAction(
        actions[action],
        { id: TEST_RULE_ID, ...request },
        state,
        [],
        [{ type: 'postRuleSuccess' }],
        () => {
          expect(mock.history.put).toEqual([
            expect.objectContaining({
              url: `${path}/${TEST_RULE_ID}`,
              data: JSON.stringify(mapApprovalRuleRequest(request)),
            }),
          ]);
        },
      );
    });
  });

  describe('deleteRuleSuccess', () => {
    it('closes modal and fetches', () => {
      return testAction(
        actions.deleteRuleSuccess,
        null,
        {},
        [],
        [{ type: 'deleteModal/close' }, { type: 'fetchRules' }],
      );
    });
  });

  describe('deleteRuleError', () => {
    it('creates a flash', () => {
      expect(createFlash).not.toHaveBeenCalled();

      actions.deleteRuleError();

      expect(createFlash.mock.calls[0]).toEqual([
        { message: expect.stringMatching('error occurred') },
      ]);
    });
  });

  describe('DELETE', () => {
    it.each`
      action                          | path
      ${'deleteRule'}                 | ${TEST_RULES_PATH}
      ${'deleteExternalApprovalRule'} | ${TEST_EXTERNAL_RULES_PATH}
    `('dispatches success on success for $action', ({ action, path }) => {
      mock.onDelete(`${path}/${TEST_RULE_ID}`).replyOnce(httpStatus.OK);

      return testAction(
        actions[action],
        TEST_RULE_ID,
        state,
        [],
        [{ type: 'deleteRuleSuccess' }],
        () => {
          expect(mock.history.delete).toEqual([
            expect.objectContaining({
              url: `${path}/${TEST_RULE_ID}`,
            }),
          ]);
        },
      );
    });

    it('dispatches error on error', () => {
      mock
        .onDelete(`${TEST_RULES_PATH}/${TEST_RULE_ID}`)
        .replyOnce(httpStatus.INTERNAL_SERVER_ERROR);

      return testAction(actions.deleteRule, TEST_RULE_ID, state, [], [{ type: 'deleteRuleError' }]);
    });
  });
});

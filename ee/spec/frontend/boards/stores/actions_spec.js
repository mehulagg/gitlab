import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import { GroupByParamType } from 'ee/boards/constants';
import actions, { gqlClient } from 'ee/boards/stores/actions';
import boardsStoreEE from 'ee/boards/stores/boards_store_ee';
import * as types from 'ee/boards/stores/mutation_types';
import { TEST_HOST } from 'helpers/test_constants';
import testAction from 'helpers/vuex_action_helper';
import { formatListIssues } from '~/boards/boards_util';
import { ListType } from '~/boards/constants';
import * as typesCE from '~/boards/stores/mutation_types';
import * as commonUtils from '~/lib/utils/common_utils';
import { mergeUrlParams, removeParams } from '~/lib/utils/url_utility';
import {
  mockLists,
  mockIssue,
  mockEpic,
  rawIssue,
  mockIssueWithModel,
  mockIssue2WithModel,
  mockListsWithModel,
} from '../mock_data';

const expectNotImplemented = action => {
  it('is not implemented', () => {
    expect(action).toThrow(new Error('Not implemented!'));
  });
};

let mock;

beforeEach(() => {
  mock = new MockAdapter(axios);
  window.gon = { features: {} };
  jest.spyOn(commonUtils, 'historyPushState');
});

afterEach(() => {
  mock.restore();
});

describe('setFilters', () => {
  it('should commit mutation SET_FILTERS, updates epicId with global id', () => {
    const state = {
      filters: {},
    };

    const filters = { labelName: 'label', epicId: 1 };
    const updatedFilters = { labelName: 'label', epicId: 'gid://gitlab/Epic/1' };

    return testAction(
      actions.setFilters,
      filters,
      state,
      [{ type: types.SET_FILTERS, payload: updatedFilters }],
      [],
    );
  });

  it('should commit mutation SET_FILTERS, updates epicWildcardId', () => {
    const state = {
      filters: {},
    };

    const filters = { labelName: 'label', epicId: 'None' };
    const updatedFilters = { labelName: 'label', epicWildcardId: 'NONE' };

    return testAction(
      actions.setFilters,
      filters,
      state,
      [{ type: types.SET_FILTERS, payload: updatedFilters }],
      [],
    );
  });

  it('should commit mutation SET_FILTERS, updates iterationWildcardId', () => {
    const state = {
      filters: {},
    };

    const filters = { labelName: 'label', iterationId: 'None' };
    const updatedFilters = { labelName: 'label', iterationWildcardId: 'NONE' };

    return testAction(
      actions.setFilters,
      filters,
      state,
      [{ type: types.SET_FILTERS, payload: updatedFilters }],
      [],
    );
  });

  it('should commit mutation SET_FILTERS, dispatches setEpicSwimlanes action if filters contain groupBy epic', () => {
    const state = {
      filters: {},
    };

    const filters = { labelName: 'label', epicId: 1, groupBy: 'epic' };
    const updatedFilters = { labelName: 'label', epicId: 'gid://gitlab/Epic/1' };

    return testAction(
      actions.setFilters,
      filters,
      state,
      [{ type: types.SET_FILTERS, payload: updatedFilters }],
      [{ type: 'setEpicSwimlanes' }],
    );
  });
});

describe('fetchEpicsSwimlanes', () => {
  const state = {
    endpoints: {
      fullPath: 'gitlab-org',
      boardId: 1,
    },
    filterParams: {},
    boardType: 'group',
  };

  const queryResponse = {
    data: {
      group: {
        board: {
          epics: {
            edges: [{ node: mockEpic }],
            pageInfo: {},
          },
        },
      },
    },
  };

  it('should commit mutation RECEIVE_EPICS_SUCCESS on success without lists', done => {
    jest.spyOn(gqlClient, 'query').mockResolvedValue(queryResponse);

    testAction(
      actions.fetchEpicsSwimlanes,
      { withLists: false },
      state,
      [
        {
          type: types.RECEIVE_EPICS_SUCCESS,
          payload: [mockEpic],
        },
      ],
      [],
      done,
    );
  });

  it('should commit mutation RECEIVE_SWIMLANES_FAILURE on failure', done => {
    jest.spyOn(gqlClient, 'query').mockResolvedValue(Promise.reject());

    testAction(
      actions.fetchEpicsSwimlanes,
      {},
      state,
      [{ type: types.RECEIVE_SWIMLANES_FAILURE }],
      [],
      done,
    );
  });

  it('should dispatch fetchEpicsSwimlanes when page info hasNextPage', done => {
    const queryResponseWithNextPage = {
      data: {
        group: {
          board: {
            epics: {
              edges: [{ node: mockEpic }],
              pageInfo: {
                hasNextPage: true,
                endCursor: 'ENDCURSOR',
              },
            },
          },
        },
      },
    };
    jest.spyOn(gqlClient, 'query').mockResolvedValue(queryResponseWithNextPage);

    testAction(
      actions.fetchEpicsSwimlanes,
      { withLists: false },
      state,
      [
        {
          type: types.RECEIVE_EPICS_SUCCESS,
          payload: [mockEpic],
        },
      ],
      [
        {
          type: 'fetchEpicsSwimlanes',
          payload: { withLists: false, endCursor: 'ENDCURSOR' },
        },
      ],
      done,
    );
  });
});

describe('updateBoardEpicUserPreferences', () => {
  const state = {
    endpoints: {
      boardId: 1,
    },
  };

  const queryResponse = (collapsed = false) => ({
    data: {
      updateBoardEpicUserPreferences: {
        errors: [],
        epicUserPreferences: { collapsed },
      },
    },
  });

  it('should send mutation', done => {
    const collapsed = true;
    jest.spyOn(gqlClient, 'mutate').mockResolvedValue(queryResponse(collapsed));

    testAction(
      actions.updateBoardEpicUserPreferences,
      { epicId: mockEpic.id, collapsed },
      state,
      [
        {
          payload: {
            epicId: mockEpic.id,
            userPreferences: {
              collapsed,
            },
          },
          type: types.SET_BOARD_EPIC_USER_PREFERENCES,
        },
      ],
      [],
      done,
    );
  });
});

describe('setShowLabels', () => {
  it('should commit mutation SET_SHOW_LABELS', done => {
    const state = {
      isShowingLabels: true,
    };

    testAction(
      actions.setShowLabels,
      false,
      state,
      [{ type: types.SET_SHOW_LABELS, payload: false }],
      [],
      done,
    );
  });
});

describe('updateListWipLimit', () => {
  let storeMock;
  const getters = { shouldUseGraphQL: false };

  beforeEach(() => {
    storeMock = {
      state: { endpoints: { listsEndpoint: '/test' } },
      create: () => {},
      setCurrentBoard: () => {},
    };

    boardsStoreEE.initEESpecific(storeMock);
    jest.mock('axios');
    axios.put = jest.fn();
    axios.put.mockResolvedValue({ data: {} });
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('axios - should call the correct url', () => {
    const maxIssueCount = 0;
    const activeId = 1;

    return actions
      .updateListWipLimit({ state: { activeId }, getters }, { maxIssueCount, listId: activeId })
      .then(() => {
        expect(axios.put).toHaveBeenCalledWith(
          `${boardsStoreEE.store.state.endpoints.listsEndpoint}/${activeId}`,
          { list: { max_issue_count: maxIssueCount } },
        );
      });
  });

  it('graphql - commit UPDATE_LIST_SUCCESS mutation on success', () => {
    const maxIssueCount = 0;
    const activeId = 1;
    getters.shouldUseGraphQL = true;
    jest.spyOn(gqlClient, 'mutate').mockResolvedValue({
      data: {
        boardListUpdateLimitMetrics: {
          list: {
            id: activeId,
          },
          errors: [],
        },
      },
    });

    return testAction(
      actions.updateListWipLimit,
      { maxIssueCount, listId: activeId },
      { isShowingEpicsSwimlanes: true, ...getters },
      [
        {
          type: types.UPDATE_LIST_SUCCESS,
          payload: {
            listId: activeId,
            list: expect.objectContaining({
              id: activeId,
            }),
          },
        },
      ],
      [],
    );
  });

  it('graphql - commit UPDATE_LIST_FAILURE mutation on failure', () => {
    const maxIssueCount = 0;
    const activeId = 1;
    getters.shouldUseGraphQL = true;
    jest.spyOn(gqlClient, 'mutate').mockResolvedValue(Promise.reject());

    return testAction(
      actions.updateListWipLimit,
      { maxIssueCount, listId: activeId },
      { isShowingEpicsSwimlanes: true, ...getters },
      [{ type: types.UPDATE_LIST_FAILURE }],
      [],
    );
  });
});

describe('showPromotionList', () => {
  it('should dispatch addList action when conditions showPromotion is true', done => {
    const state = {
      endpoints: { fullPath: 'gitlab-org', boardId: '1' },
      boardType: 'group',
      disabled: false,
      boardLists: [{ type: 'backlog' }, { type: 'closed' }],
      showPromotion: true,
    };

    const promotionList = {
      id: 'promotion',
      listType: ListType.promotion,
      title: 'Improve Issue Boards',
      position: 0,
    };

    testAction(
      actions.showPromotionList,
      {},
      state,
      [],
      [{ type: 'addList', payload: promotionList }],
      done,
    );
  });
});

describe('fetchAllBoards', () => {
  expectNotImplemented(actions.fetchAllBoards);
});

describe('fetchRecentBoards', () => {
  expectNotImplemented(actions.fetchRecentBoards);
});

describe('createBoard', () => {
  expectNotImplemented(actions.createBoard);
});

describe('deleteBoard', () => {
  expectNotImplemented(actions.deleteBoard);
});

describe('updateIssueWeight', () => {
  expectNotImplemented(actions.updateIssueWeight);
});

describe('togglePromotionState', () => {
  expectNotImplemented(actions.updateIssueWeight);
});

describe('fetchIssuesForEpic', () => {
  const listId = mockLists[0].id;
  const epicId = mockEpic.id;

  const state = {
    endpoints: {
      fullPath: 'gitlab-org',
      boardId: 1,
    },
    filterParams: {},
    boardType: 'group',
  };

  const queryResponse = {
    data: {
      group: {
        board: {
          lists: {
            nodes: [
              {
                id: listId,
                issues: {
                  edges: [{ node: [mockIssue] }],
                },
              },
            ],
          },
        },
      },
    },
  };

  const formattedIssues = formatListIssues(queryResponse.data.group.board.lists);

  it('should commit mutations REQUEST_ISSUES_FOR_EPIC and RECEIVE_ISSUES_FOR_LIST_SUCCESS on success', done => {
    jest.spyOn(gqlClient, 'query').mockResolvedValue(queryResponse);

    testAction(
      actions.fetchIssuesForEpic,
      epicId,
      state,
      [
        { type: types.REQUEST_ISSUES_FOR_EPIC, payload: epicId },
        { type: types.RECEIVE_ISSUES_FOR_EPIC_SUCCESS, payload: { ...formattedIssues, epicId } },
      ],
      [],
      done,
    );
  });

  it('should commit mutations REQUEST_ISSUES_FOR_EPIC and RECEIVE_ISSUES_FOR_LIST_FAILURE on failure', done => {
    jest.spyOn(gqlClient, 'query').mockResolvedValue(Promise.reject());

    testAction(
      actions.fetchIssuesForEpic,
      epicId,
      state,
      [
        { type: types.REQUEST_ISSUES_FOR_EPIC, payload: epicId },
        { type: types.RECEIVE_ISSUES_FOR_EPIC_FAILURE, payload: epicId },
      ],
      [],
      done,
    );
  });
});

describe('toggleEpicSwimlanes', () => {
  it('should commit mutation TOGGLE_EPICS_SWIMLANES', () => {
    global.jsdom.reconfigure({
      url: `${TEST_HOST}/groups/gitlab-org/-/boards/1?group_by=epic`,
    });

    const state = {
      isShowingEpicsSwimlanes: false,
      endpoints: {
        fullPath: 'gitlab-org',
        boardId: 1,
      },
    };

    return testAction(
      actions.toggleEpicSwimlanes,
      null,
      state,
      [{ type: types.TOGGLE_EPICS_SWIMLANES }],
      [],
      () => {
        expect(commonUtils.historyPushState).toHaveBeenCalledWith(removeParams(['group_by']));
        expect(global.window.location.href).toBe(`${TEST_HOST}/groups/gitlab-org/-/boards/1`);
      },
    );
  });

  it('should dispatch fetchEpicsSwimlanes action when isShowingEpicsSwimlanes is true', () => {
    global.jsdom.reconfigure({
      url: `${TEST_HOST}/groups/gitlab-org/-/boards/1`,
    });

    jest.spyOn(gqlClient, 'query').mockResolvedValue({});

    const state = {
      isShowingEpicsSwimlanes: true,
      endpoints: {
        fullPath: 'gitlab-org',
        boardId: 1,
      },
    };

    return testAction(
      actions.toggleEpicSwimlanes,
      null,
      state,
      [{ type: types.TOGGLE_EPICS_SWIMLANES }],
      [{ type: 'fetchEpicsSwimlanes', payload: {} }],
      () => {
        expect(commonUtils.historyPushState).toHaveBeenCalledWith(
          mergeUrlParams({ group_by: GroupByParamType.epic }, window.location.href),
        );
        expect(global.window.location.href).toBe(
          `${TEST_HOST}/groups/gitlab-org/-/boards/1?group_by=epic`,
        );
      },
    );
  });
});

describe('setEpicSwimlanes', () => {
  it('should commit mutation SET_EPICS_SWIMLANES and dispatch fetchEpicsSwimlanes action', () => {
    jest.spyOn(gqlClient, 'query').mockResolvedValue({});

    return testAction(
      actions.setEpicSwimlanes,
      null,
      {},
      [{ type: types.SET_EPICS_SWIMLANES }],
      [{ type: 'fetchEpicsSwimlanes', payload: {} }],
    );
  });
});

describe('resetEpics', () => {
  it('commits RESET_EPICS mutation', () => {
    return testAction(actions.resetEpics, {}, {}, [{ type: types.RESET_EPICS }], []);
  });
});

describe('setActiveIssueEpic', () => {
  const getters = { activeIssue: mockIssue };
  const epicWithData = {
    id: 'gid://gitlab/Epic/42',
    iid: 1,
    title: 'Epic title',
  };
  const input = {
    epicId: epicWithData.id,
    projectPath: 'h/b',
  };

  it('should return epic after setting the issue', async () => {
    jest
      .spyOn(gqlClient, 'mutate')
      .mockResolvedValue({ data: { issueSetEpic: { issue: { epic: epicWithData } } } });

    const result = await actions.setActiveIssueEpic({ getters }, input);

    expect(result.id).toEqual(epicWithData.id);
  });

  it('throws error if fails', async () => {
    jest
      .spyOn(gqlClient, 'mutate')
      .mockResolvedValue({ data: { issueSetEpic: { errors: ['failed mutation'] } } });

    await expect(actions.setActiveIssueEpic({ getters }, input)).rejects.toThrow(Error);
  });
});

describe('setActiveIssueWeight', () => {
  const state = { issues: { [mockIssue.id]: mockIssue } };
  const getters = { activeIssue: mockIssue };
  const testWeight = mockIssue.weight + 1;
  const input = {
    weight: testWeight,
    projectPath: 'h/b',
  };

  it('should commit weight after setting the issue', done => {
    jest.spyOn(gqlClient, 'mutate').mockResolvedValue({
      data: {
        issueSetWeight: {
          issue: {
            weight: testWeight,
          },
          errors: [],
        },
      },
    });

    const payload = {
      issueId: getters.activeIssue.id,
      prop: 'weight',
      value: testWeight,
    };

    testAction(
      actions.setActiveIssueWeight,
      input,
      { ...state, ...getters },
      [
        {
          type: typesCE.UPDATE_ISSUE_BY_ID,
          payload,
        },
      ],
      [],
      done,
    );
  });

  it('throws error if fails', async () => {
    jest
      .spyOn(gqlClient, 'mutate')
      .mockResolvedValue({ data: { issueSetWeight: { errors: ['failed mutation'] } } });

    await expect(actions.setActiveIssueWeight({ getters }, input)).rejects.toThrow(Error);
  });
});

describe('moveIssue', () => {
  const epicId = 'gid://gitlab/Epic/1';

  const listIssues = {
    'gid://gitlab/List/1': [436, 437],
    'gid://gitlab/List/2': [],
  };

  const issues = {
    '436': mockIssueWithModel,
    '437': mockIssue2WithModel,
  };

  const state = {
    endpoints: { fullPath: 'gitlab-org', boardId: '1' },
    boardType: 'group',
    disabled: false,
    boardLists: mockListsWithModel,
    issuesByListId: listIssues,
    issues,
  };

  it('should commit MOVE_ISSUE mutation and MOVE_ISSUE_SUCCESS mutation when successful', done => {
    jest.spyOn(gqlClient, 'mutate').mockResolvedValue({
      data: {
        issueMoveList: {
          issue: rawIssue,
          errors: [],
        },
      },
    });

    testAction(
      actions.moveIssue,
      {
        issueId: '436',
        issueIid: mockIssue.iid,
        issuePath: mockIssue.referencePath,
        fromListId: 'gid://gitlab/List/1',
        toListId: 'gid://gitlab/List/2',
        epicId,
      },
      state,
      [
        {
          type: types.MOVE_ISSUE,
          payload: {
            originalIssue: mockIssueWithModel,
            fromListId: 'gid://gitlab/List/1',
            toListId: 'gid://gitlab/List/2',
            epicId,
          },
        },
        {
          type: types.MOVE_ISSUE_SUCCESS,
          payload: { issue: rawIssue },
        },
      ],
      [],
      done,
    );
  });

  it('should commit MOVE_ISSUE mutation and MOVE_ISSUE_FAILURE mutation when unsuccessful', done => {
    jest.spyOn(gqlClient, 'mutate').mockResolvedValue({
      data: {
        issueMoveList: {
          issue: {},
          errors: [{ foo: 'bar' }],
        },
      },
    });

    testAction(
      actions.moveIssue,
      {
        issueId: '436',
        issueIid: mockIssue.iid,
        issuePath: mockIssue.referencePath,
        fromListId: 'gid://gitlab/List/1',
        toListId: 'gid://gitlab/List/2',
        epicId,
      },
      state,
      [
        {
          type: types.MOVE_ISSUE,
          payload: {
            originalIssue: mockIssueWithModel,
            fromListId: 'gid://gitlab/List/1',
            toListId: 'gid://gitlab/List/2',
            epicId,
          },
        },
        {
          type: types.MOVE_ISSUE_FAILURE,
          payload: {
            originalIssue: mockIssueWithModel,
            fromListId: 'gid://gitlab/List/1',
            toListId: 'gid://gitlab/List/2',
            originalIndex: 0,
          },
        },
      ],
      [],
      done,
    );
  });
});

import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import boardsStoreEE from 'ee/boards/stores/boards_store_ee';
import actions, { gqlClient } from 'ee/boards/stores/actions';
import * as types from 'ee/boards/stores/mutation_types';
import testAction from 'helpers/vuex_action_helper';
import { ListType } from '~/boards/constants';
import { formatListIssues } from '~/boards/boards_util';
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
});

afterEach(() => {
  mock.restore();
});

describe('setFilters', () => {
  it('should commit mutation SET_FILTERS, updates epicId with global id', done => {
    const state = {
      filters: {},
    };

    const filters = { labelName: 'label', epicId: 1 };
    const updatedFilters = { labelName: 'label', epicId: 'gid://gitlab/Epic/1' };

    testAction(
      actions.setFilters,
      filters,
      state,
      [{ type: types.SET_FILTERS, payload: updatedFilters }],
      [],
      done,
    );
  });

  it('should commit mutation SET_FILTERS, updates epicWildcardId', done => {
    const state = {
      filters: {},
    };

    const filters = { labelName: 'label', epicId: 'None' };
    const updatedFilters = { labelName: 'label', epicWildcardId: 'NONE' };

    testAction(
      actions.setFilters,
      filters,
      state,
      [{ type: types.SET_FILTERS, payload: updatedFilters }],
      [],
      done,
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
          payload: { epics: [mockEpic] },
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
          payload: { epics: [mockEpic] },
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

  it('should call the correct url', () => {
    const maxIssueCount = 0;
    const activeId = 1;

    return actions.updateListWipLimit({ state: { activeId } }, { maxIssueCount }).then(() => {
      expect(axios.put).toHaveBeenCalledWith(
        `${boardsStoreEE.store.state.endpoints.listsEndpoint}/${activeId}`,
        { list: { max_issue_count: maxIssueCount } },
      );
    });
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
                  nodes: [mockIssue],
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
    );
  });
});

describe('resetEpics', () => {
  it('commits RESET_EPICS mutation', () => {
    return testAction(actions.resetEpics, {}, {}, [{ type: types.RESET_EPICS }], []);
  });
});

describe('setActiveIssueEpic', () => {
  const getters = { getActiveIssue: mockIssue };
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

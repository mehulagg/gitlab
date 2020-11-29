import { dateTypes } from 'ee/epic/constants';
import * as types from 'ee/epic/store/mutation_types';
import mutations from 'ee/epic/store/mutations';

import { mockEpicMeta, mockEpicData } from '../mock_data';

describe('Epic Store Mutations', () => {
  describe('SET_EPIC_META', () => {
    it('Should add Epic meta to state', () => {
      const state = {};
      mutations[types.SET_EPIC_META](state, mockEpicMeta);

      expect(state).toEqual(mockEpicMeta);
    });
  });

  describe('SET_EPIC_DATA', () => {
    it('Should add Epic data to state', () => {
      const state = {};
      mutations[types.SET_EPIC_DATA](state, mockEpicData);

      expect(state).toEqual(mockEpicData);
    });
  });

  describe('REQUEST_EPIC_STATUS_CHANGE', () => {
    it('Should set `epicStatusChangeInProgress` flag on state as `true`', () => {
      const state = {};
      mutations[types.REQUEST_EPIC_STATUS_CHANGE](state);

      expect(state.epicStatusChangeInProgress).toBe(true);
    });
  });

  describe('REQUEST_EPIC_STATUS_CHANGE_SUCCESS', () => {
    it('Should set `epicStatusChangeInProgress` flag on state as `false` and update Epic `state`', () => {
      const state = {
        state: 'opened',
      };
      mutations[types.REQUEST_EPIC_STATUS_CHANGE_SUCCESS](state, { state: 'closed' });

      expect(state.epicStatusChangeInProgress).toBe(false);
      expect(state.state).toBe('closed');
    });
  });

  describe('REQUEST_EPIC_STATUS_CHANGE_FAILURE', () => {
    it('Should set `epicStatusChangeInProgress` flag on state as `false`', () => {
      const state = {};
      mutations[types.REQUEST_EPIC_STATUS_CHANGE_FAILURE](state);

      expect(state.epicStatusChangeInProgress).toBe(false);
    });
  });

  describe('TOGGLE_SIDEBAR', () => {
    it('Should set `sidebarCollapsed` flag on state with value of provided `sidebarCollapsed` param', () => {
      const state = {};
      const sidebarCollapsed = true;

      mutations[types.TOGGLE_SIDEBAR](state, sidebarCollapsed);

      expect(state.sidebarCollapsed).toBe(sidebarCollapsed);
    });
  });

  describe('REQUEST_EPIC_TODO_TOGGLE', () => {
    it('Should set `epicTodoToggleInProgress` flag on state as `true`', () => {
      const state = {
        epicTodoToggleInProgress: false,
      };

      mutations[types.REQUEST_EPIC_TODO_TOGGLE](state);

      expect(state.epicTodoToggleInProgress).toBe(true);
    });
  });

  describe('REQUEST_EPIC_TODO_TOGGLE_SUCCESS', () => {
    it('Should set `todoDeletePath` value on state with provided value of `todoDeletePath` param', () => {
      const todoDeletePath = '/foo/bar';
      const state = {};

      mutations[types.REQUEST_EPIC_TODO_TOGGLE_SUCCESS](state, { todoDeletePath });

      expect(state.todoDeletePath).toBe(todoDeletePath);
    });

    it('Should toggle value of `todoExists` value on state', () => {
      const state = {
        todoExists: true,
      };

      mutations[types.REQUEST_EPIC_TODO_TOGGLE_SUCCESS](state, {});

      expect(state.todoExists).toBe(false);
    });

    it('Should set `epicTodoToggleInProgress` flag on state as `false`', () => {
      const state = {
        epicTodoToggleInProgress: true,
      };

      mutations[types.REQUEST_EPIC_TODO_TOGGLE_SUCCESS](state, {});

      expect(state.epicTodoToggleInProgress).toBe(false);
    });
  });

  describe('REQUEST_EPIC_TODO_TOGGLE_FAILURE', () => {
    it('Should set `epicTodoToggleInProgress` flag on state as `false`', () => {
      const state = {
        epicTodoToggleInProgress: true,
      };

      mutations[types.REQUEST_EPIC_TODO_TOGGLE_FAILURE](state);

      expect(state.epicTodoToggleInProgress).toBe(false);
    });
  });

  describe('TOGGLE_EPIC_START_DATE_TYPE', () => {
    it('Should set `startDateIsFixed` flag on state based on provided `dateTypeIsFixed` param', () => {
      const state = {
        startDateIsFixed: false,
      };

      mutations[types.TOGGLE_EPIC_START_DATE_TYPE](state, {
        dateTypeIsFixed: true,
      });

      expect(state.startDateIsFixed).toBe(true);
    });
  });

  describe('TOGGLE_EPIC_DUE_DATE_TYPE', () => {
    it('Should set `dueDateIsFixed` flag on state based on provided `dateTypeIsFixed` param', () => {
      const state = {
        dueDateIsFixed: false,
      };

      mutations[types.TOGGLE_EPIC_DUE_DATE_TYPE](state, {
        dateTypeIsFixed: true,
      });

      expect(state.dueDateIsFixed).toBe(true);
    });
  });

  describe('REQUEST_EPIC_DATE_SAVE', () => {
    it('Should set `epicStartDateSaveInProgress` flag on state as `true` when provided `dateType` param is `start`', () => {
      const state = {
        epicStartDateSaveInProgress: false,
      };

      mutations[types.REQUEST_EPIC_DATE_SAVE](state, {
        dateType: dateTypes.start,
      });

      expect(state.epicStartDateSaveInProgress).toBe(true);
    });

    it('Should set `epicDueDateSaveInProgress` flag on state as `true` when provided `dateType` param is `due`', () => {
      const state = {
        epicDueDateSaveInProgress: false,
      };

      mutations[types.REQUEST_EPIC_DATE_SAVE](state, {
        dateType: dateTypes.due,
      });

      expect(state.epicDueDateSaveInProgress).toBe(true);
    });
  });

  describe('REQUEST_EPIC_DATE_SAVE_SUCCESS', () => {
    it('Should set `epicStartDateSaveInProgress` flag on state to `false` and set `startDateIsFixed` & `startDate` values based on provided `dateTypeIsFixed` & `newDate` params when `dateType` param is `start`', () => {
      const startDateIsFixed = true;
      const startDate = '2018-1-1';
      const state = {};

      mutations[types.REQUEST_EPIC_DATE_SAVE_SUCCESS](state, {
        dateType: dateTypes.start,
        dateTypeIsFixed: startDateIsFixed,
        newDate: startDate,
      });

      expect(state.epicStartDateSaveInProgress).toBe(false);
      expect(state.startDateIsFixed).toBe(startDateIsFixed);
      expect(state.startDate).toBe(startDate);
      expect(state.startDateFixed).toBe(startDate);
    });

    it('Should set `epicDueDateSaveInProgress` flag on state to `false` and set `dueDateIsFixed` & `dueDate` values based on provided `dateTypeIsFixed` & `newDate` params when `dateType` param is `due`', () => {
      const dueDateIsFixed = true;
      const dueDate = '2018-1-1';
      const state = {};

      mutations[types.REQUEST_EPIC_DATE_SAVE_SUCCESS](state, {
        dateType: dateTypes.due,
        dateTypeIsFixed: dueDateIsFixed,
        newDate: dueDate,
      });

      expect(state.epicDueDateSaveInProgress).toBe(false);
      expect(state.dueDateIsFixed).toBe(dueDateIsFixed);
      expect(state.dueDate).toBe(dueDate);
      expect(state.dueDateFixed).toBe(dueDate);
    });

    it('Should not set `startDateFixed` on state when date changed is not of type fixed', () => {
      const startDateIsFixed = false;
      const startDate = '2018-1-1';
      const state = {};

      mutations[types.REQUEST_EPIC_DATE_SAVE_SUCCESS](state, {
        dateType: dateTypes.start,
        dateTypeIsFixed: startDateIsFixed,
        newDate: startDate,
      });

      expect(state.startDateFixed).toBeUndefined();
    });

    it('Should not set `dueDateFixed` on state when date changed is not of type fixed', () => {
      const dueDateIsFixed = false;
      const dueDate = '2018-1-1';
      const state = {};

      mutations[types.REQUEST_EPIC_DATE_SAVE_SUCCESS](state, {
        dateType: dateTypes.due,
        dateTypeIsFixed: dueDateIsFixed,
        newDate: dueDate,
      });

      expect(state.dueDateFixed).toBeUndefined();
    });
  });

  describe('REQUEST_EPIC_DATE_SAVE_FAILURE', () => {
    it('Should set `epicStartDateSaveInProgress` flag on state to `false` and set `startDateIsFixed` value with provided `dateTypeIsFixed` param when `dateType` param is `start`', () => {
      const startDateIsFixed = true;
      const state = {};

      mutations[types.REQUEST_EPIC_DATE_SAVE_FAILURE](state, {
        dateType: dateTypes.start,
        dateTypeIsFixed: startDateIsFixed,
      });

      expect(state.epicStartDateSaveInProgress).toBe(false);
      expect(state.startDateIsFixed).toBe(startDateIsFixed);
    });

    it('Should set `epicDueDateSaveInProgress` flag on state to `false` and set `dueDateIsFixed` value with provided `dateTypeIsFixed` param when `dateType` param is `due`', () => {
      const dueDateIsFixed = true;
      const state = {};

      mutations[types.REQUEST_EPIC_DATE_SAVE_FAILURE](state, {
        dateType: dateTypes.due,
        dateTypeIsFixed: dueDateIsFixed,
      });

      expect(state.epicDueDateSaveInProgress).toBe(false);
      expect(state.dueDateIsFixed).toBe(dueDateIsFixed);
    });
  });

  describe('REQUEST_EPIC_SUBSCRIPTION_TOGGLE', () => {
    it('Should set `epicSubscriptionToggleInProgress` flag on state as `true`', () => {
      const state = {
        epicSubscriptionToggleInProgress: false,
      };

      mutations[types.REQUEST_EPIC_SUBSCRIPTION_TOGGLE](state);

      expect(state.epicSubscriptionToggleInProgress).toBe(true);
    });
  });

  describe('REQUEST_EPIC_SUBSCRIPTION_TOGGLE_SUCCESS', () => {
    it('Should set `epicSubscriptionToggleInProgress` flag on state as `false` and set value of provided `subscribed` param on state', () => {
      const state = {
        epicSubscriptionToggleInProgress: true,
        subscribed: false,
      };

      mutations[types.REQUEST_EPIC_SUBSCRIPTION_TOGGLE_SUCCESS](state, {
        subscribed: true,
      });

      expect(state.epicSubscriptionToggleInProgress).toBe(false);
      expect(state.subscribed).toBe(true);
    });
  });

  describe('REQUEST_EPIC_SUBSCRIPTION_TOGGLE_FAILURE', () => {
    it('Should set `epicSubscriptionToggleInProgress` flag on state as `false`', () => {
      const state = {
        epicSubscriptionToggleInProgress: true,
      };

      mutations[types.REQUEST_EPIC_SUBSCRIPTION_TOGGLE_FAILURE](state);

      expect(state.epicSubscriptionToggleInProgress).toBe(false);
    });
  });

  describe('SET_EPIC_CREATE_TITLE', () => {
    it('Should set `newEpicTitle` prop on state as with the value of provided `newEpicTitle` param', () => {
      const state = {
        newEpicTitle: '',
      };

      mutations[types.SET_EPIC_CREATE_TITLE](state, {
        newEpicTitle: 'foobar',
      });

      expect(state.newEpicTitle).toBe('foobar');
    });
  });

  describe('SET_EPIC_CREATE_CONFIDENTIAL', () => {
    it('Should set `newEpicConfidential` prop on state as with the value of provided `newEpicConfidential` param', () => {
      const state = {
        newEpicConfidential: true,
      };

      mutations[types.SET_EPIC_CREATE_CONFIDENTIAL](state, {
        newEpicConfidential: true,
      });

      expect(state.newEpicConfidential).toBe(true);
    });
  });

  describe('REQUEST_EPIC_CREATE', () => {
    it('Should set `epicCreateInProgress` flag on state as `true`', () => {
      const state = {
        epicCreateInProgress: false,
      };

      mutations[types.REQUEST_EPIC_CREATE](state);

      expect(state.epicCreateInProgress).toBe(true);
    });
  });

  describe('REQUEST_EPIC_CREATE_FAILURE', () => {
    it('Should set `epicCreateInProgress` flag on state as `false`', () => {
      const state = {
        epicCreateInProgress: true,
      };

      mutations[types.REQUEST_EPIC_CREATE_FAILURE](state);

      expect(state.epicCreateInProgress).toBe(false);
    });
  });

  describe('REQUEST_EPIC_LABELS_SELECT', () => {
    it('Should set `epicLabelsSelectInProgress` flag on state to `true`', () => {
      const state = {
        epicLabelsSelectInProgress: false,
      };

      mutations[types.REQUEST_EPIC_LABELS_SELECT](state);

      expect(state.epicLabelsSelectInProgress).toBe(true);
    });
  });

  describe('RECEIVE_EPIC_LABELS_SELECT_SUCCESS', () => {
    it('Should update `labels` array on state when new labels are added', () => {
      const addedLabels = [{ id: 1, set: true }, { id: 2, set: true }];
      const state = {
        labels: [],
      };

      mutations[types.RECEIVE_EPIC_LABELS_SELECT_SUCCESS](state, addedLabels);

      expect(state.labels).toEqual(expect.arrayContaining(addedLabels));
    });

    it('Should update `labels` array on state when existing labels are removed', () => {
      const removedLabels = [{ id: 1, set: false }];
      const state = {
        labels: [{ id: 1, set: true }, { id: 2, set: true }],
      };

      mutations[types.RECEIVE_EPIC_LABELS_SELECT_SUCCESS](state, removedLabels);

      expect(state.labels).toEqual(expect.arrayContaining([{ id: 2, set: true }]));
    });

    it('Should update `labels` array on state when some labels are added and some are removed', () => {
      const removedLabels = [{ id: 1, set: false }];
      const addedLabels = [{ id: 3, set: true }];
      const state = {
        labels: [{ id: 1, set: true }, { id: 2, set: true }],
      };

      mutations[types.RECEIVE_EPIC_LABELS_SELECT_SUCCESS](state, [
        ...addedLabels,
        ...removedLabels,
      ]);

      expect(state.labels).toEqual(
        expect.arrayContaining([{ id: 2, set: true }, { id: 3, set: true }]),
      );
    });
  });

  describe('RECEIVE_EPIC_LABELS_SELECT_FAILURE', () => {
    it('Should set `epicLabelsSelectInProgress` flag on state to `false`', () => {
      const state = {
        epicLabelsSelectInProgress: true,
      };

      mutations[types.RECEIVE_EPIC_LABELS_SELECT_FAILURE](state);

      expect(state.epicLabelsSelectInProgress).toBe(false);
    });
  });

  describe('SET_EPIC_CONFIDENTIAL', () => {
    it('Should set `confidential` flag on state to `true`', () => {
      const state = {
        confidential: false,
      };

      const confidential = true;

      mutations[types.SET_EPIC_CONFIDENTIAL](state, confidential);

      expect(state.confidential).toBe(true);
    });
  });
});

import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import * as actions from 'ee/analytics/cycle_analytics/store/modules/custom_stages/actions';
import * as types from 'ee/analytics/cycle_analytics/store/modules/custom_stages/mutation_types';
import testAction from 'helpers/vuex_action_helper';
import createFlash from '~/flash';
import httpStatusCodes from '~/lib/utils/http_status';
import { currentGroup, endpoints, rawCustomStage } from '../../../mock_data';

jest.mock('~/flash');

describe('Custom stage actions', () => {
  let state;
  let mock;
  const selectedStage = rawCustomStage;

  beforeEach(() => {
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    mock.restore();
    state = { currentGroup: null };
  });

  describe('createStage', () => {
    describe('with valid data', () => {
      const customStageData = {
        startEventIdentifier: 'start_event',
        endEventIdentifier: 'end_event',
        name: 'cool-new-stage',
      };

      beforeEach(() => {
        state = { ...state, currentGroup };
        mock.onPost(endpoints.baseStagesEndpointstageData).reply(201, customStageData);
      });

      it(`dispatches the 'receiveCreateStageSuccess' action`, () =>
        testAction(
          actions.createStage,
          customStageData,
          state,
          [],
          [
            { type: 'clearFormErrors' },
            { type: 'setSavingCustomStage' },
            {
              type: 'receiveCreateStageSuccess',
              payload: { data: customStageData, status: 201 },
            },
          ],
        ));
    });

    describe('with errors', () => {
      const message = 'failed';
      const errors = {
        endEventIdentifier: ['Cant be blank'],
      };
      const customStageData = {
        startEventIdentifier: 'start_event',
        endEventIdentifier: '',
        name: 'cool-new-stage',
      };

      beforeEach(() => {
        state = { ...state, currentGroup };
        mock
          .onPost(endpoints.baseStagesEndpointstageData)
          .reply(httpStatusCodes.UNPROCESSABLE_ENTITY, {
            message,
            errors,
          });
      });

      it(`dispatches the 'receiveCreateStageError' action`, () =>
        testAction(
          actions.createStage,
          customStageData,
          state,
          [],
          [
            { type: 'clearFormErrors' },
            { type: 'setSavingCustomStage' },
            {
              type: 'receiveCreateStageError',
              payload: {
                data: customStageData,
                errors,
                message,
                status: httpStatusCodes.UNPROCESSABLE_ENTITY,
              },
            },
          ],
        ));
    });
  });

  describe('receiveCreateStageError', () => {
    const response = {
      data: { name: 'uh oh' },
    };

    beforeEach(() => {});

    it('will commit the RECEIVE_CREATE_STAGE_ERROR mutation', () =>
      testAction(
        actions.receiveCreateStageError,
        response,
        state,
        [{ type: types.RECEIVE_CREATE_STAGE_ERROR }],
        [{ type: 'setStageFormErrors', payload: {} }],
      ));

    it('will flash an error message', () => {
      return actions
        .receiveCreateStageError(
          {
            dispatch: () => Promise.resolve(),
            commit: () => {},
          },
          response,
        )
        .then(() => {
          expect(createFlash).toHaveBeenCalledWith({
            message: 'There was a problem saving your custom stage, please try again',
          });
        });
    });

    describe('with a stage name error', () => {
      it('will flash an error message', () => {
        return actions
          .receiveCreateStageError(
            {
              dispatch: () => Promise.resolve(),
              commit: () => {},
            },
            {
              ...response,
              status: httpStatusCodes.UNPROCESSABLE_ENTITY,
              errors: { name: ['is reserved'] },
            },
          )
          .then(() => {
            expect(createFlash).toHaveBeenCalledWith({ message: "'uh oh' stage already exists" });
          });
      });
    });
  });

  describe('receiveCreateStageSuccess', () => {
    const response = {
      data: {
        title: 'COOL',
      },
    };

    it('will dispatch fetchGroupStagesAndEvents', () =>
      testAction(
        actions.receiveCreateStageSuccess,
        response,
        state,
        [{ type: types.RECEIVE_CREATE_STAGE_SUCCESS }],
        [{ type: 'fetchGroupStagesAndEvents', payload: null }, { type: 'clearSavingCustomStage' }],
      ));

    describe('with an error', () => {
      it('will flash an error message', () =>
        actions
          .receiveCreateStageSuccess(
            {
              dispatch: () => Promise.reject(),
              commit: () => {},
            },
            response,
          )
          .then(() => {
            expect(createFlash).toHaveBeenCalledWith({
              message: 'There was a problem refreshing the data, please try again',
            });
          }));
    });
  });

  describe('setStageFormErrors', () => {
    it('commits the "SET_STAGE_FORM_ERRORS" mutation', () => {
      return testAction(
        actions.setStageFormErrors,
        [],
        state,
        [{ type: types.SET_STAGE_FORM_ERRORS, payload: [] }],
        [],
      );
    });
  });

  describe('clearFormErrors', () => {
    it('commits the "CLEAR_FORM_ERRORS" mutation', () => {
      return testAction(
        actions.clearFormErrors,
        [],
        state,
        [{ type: types.CLEAR_FORM_ERRORS }],
        [],
      );
    });
  });

  describe('setStageEvents', () => {
    it('commits the "SET_STAGE_EVENTS" mutation', () => {
      return testAction(
        actions.setStageEvents,
        [],
        state,
        [{ type: types.SET_STAGE_EVENTS, payload: [] }],
        [],
      );
    });
  });

  describe('hideForm', () => {
    it('commits the "HIDE_FORM" mutation', () => {
      return testAction(actions.hideForm, null, state, [{ type: types.HIDE_FORM }], []);
    });
  });

  describe('showCreateForm', () => {
    it('commits the "SHOW_CREATE_FORM" mutation', () => {
      return testAction(
        actions.showCreateForm,
        null,
        state,
        [
          { type: types.SET_LOADING },
          { type: types.SET_FORM_INITIAL_DATA },
          { type: types.SHOW_CREATE_FORM },
        ],
        [],
      );
    });
  });

  describe('showEditForm', () => {
    it('commits the "SHOW_EDIT_FORM" mutation with initial data', () => {
      return testAction(
        actions.showEditForm,
        selectedStage,
        state,
        [
          { type: types.SET_LOADING },
          { type: types.SET_FORM_INITIAL_DATA, payload: rawCustomStage },
          { type: types.SHOW_EDIT_FORM },
        ],
        [{ type: 'setSelectedStage', payload: rawCustomStage }, { type: 'clearSavingCustomStage' }],
      );
    });
  });
});

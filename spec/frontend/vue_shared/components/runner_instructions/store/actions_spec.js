import MockAdapter from 'axios-mock-adapter';
import testAction from 'helpers/vuex_action_helper';
import axios from '~/lib/utils/axios_utils';
import statusCodes from '~/lib/utils/http_status';
import * as actions from '~/vue_shared/components/runner_instructions/store/actions';
import * as types from '~/vue_shared/components/runner_instructions/store/mutation_types';
import createState from '~/vue_shared/components/runner_instructions/store/state';
import { mockPlatformsArray } from '../mock_data';

describe('Runner Instructions actions', () => {
  let state;
  let axiosMock;

  beforeEach(() => {
    state = createState();
    axiosMock = new MockAdapter(axios);
  });

  afterEach(() => {
    axiosMock.restore();
  });

  describe('selectPlatform', () => {
    it('commits the SET_AVAILABLE_PLATFORM mutation', done => {
      testAction(
        actions.selectPlatform,
        null,
        state,
        [{ type: types.SET_AVAILABLE_PLATFORM, payload: null }],
        [],
        done,
      );
    });
  });

  describe('selectArchitecture', () => {
    it('commits the SET_ARCHITECTURE mutation', done => {
      testAction(
        actions.selectArchitecture,
        null,
        state,
        [{ type: types.SET_ARCHITECTURE, payload: null }],
        [],
        done,
      );
    });
  });

  describe('requestOsInstructions', () => {
    describe('successful request', () => {
      beforeEach(() => {
        state.instructionsPath = '/instructions';
        axiosMock.onGet(state.instructionsPath).reply(statusCodes.OK, {
          available_platforms: mockPlatformsArray,
        });
      });

      it('commits the SET_AVAILABLE_PLATFORMS mutation', done => {
        testAction(
          actions.requestOsInstructions,
          null,
          state,
          [{ type: types.SET_AVAILABLE_PLATFORMS, payload: mockPlatformsArray }],
          [],
          done,
        );
      });
    });

    describe('unsuccessful request', () => {
      beforeEach(() => {
        state.instructionsPath = '/instructions';
        axiosMock.onGet(state.instructionsPath).reply(500);
      });

      it('shows an error', done => {
        testAction(actions.requestOsInstructions, null, state, [], [], done);
      });
    });
  });
});

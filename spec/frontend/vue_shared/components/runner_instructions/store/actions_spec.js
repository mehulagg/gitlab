import MockAdapter from 'axios-mock-adapter';
import testAction from 'helpers/vuex_action_helper';
import axios from '~/lib/utils/axios_utils';
import statusCodes from '~/lib/utils/http_status';
import * as actions from '~/vue_shared/components/runner_instructions/store/actions';
import * as types from '~/vue_shared/components/runner_instructions/store/mutation_types';
import createState from '~/vue_shared/components/runner_instructions/store/state';
import { mockPlatformsObject, mockInstructions } from '../mock_data';

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
    it('commits the SET_AVAILABLE_PLATFORM mutation and calls two actions', done => {
      testAction(
        actions.selectPlatform,
        null,
        state,
        [{ type: types.SET_AVAILABLE_PLATFORM, payload: null }],
        [{ type: 'selectArchitecture', payload: '' }, { type: 'requestPlatformsInstructions' }],
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

  describe('requestPlatformsInstructions', () => {
    describe('successful request', () => {
      beforeEach(() => {
        state.instructionsPath = '/instructions';
        state.selectedAvailablePlatform = 'linux';
        state.selectedArchitecture = 'amd64';
        axiosMock
          .onGet(`${state.instructionsPath}?os=linux&arch=amd64`)
          .reply(statusCodes.OK, mockInstructions);
      });

      it('commits the SET_INSTRUCTIONS mutation', done => {
        testAction(
          actions.requestPlatformsInstructions,
          null,
          state,
          [{ type: types.SET_INSTRUCTIONS, payload: mockInstructions }],
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
        testAction(actions.requestPlatformsInstructions, null, state, [], [], done);
      });
    });
  });

  describe('requestPlatforms', () => {
    describe('successful request', () => {
      beforeEach(() => {
        state.platformsPath = '/platforms';
        axiosMock.onGet(state.platformsPath).reply(statusCodes.OK, mockPlatformsObject);
      });

      it('commits the SET_AVAILABLE_PLATFORMS mutation', done => {
        testAction(
          actions.requestPlatforms,
          null,
          state,
          [
            { type: types.SET_AVAILABLE_PLATFORMS, payload: mockPlatformsObject },
            { type: types.SET_AVAILABLE_PLATFORM, payload: 'linux' },
          ],
          [],
          done,
        );
      });
    });

    describe('unsuccessful request', () => {
      beforeEach(() => {
        state.platformsPath = '/instructions';
        axiosMock.onGet(state.platformsPath).reply(500);
      });

      it('shows an error', done => {
        testAction(actions.requestPlatforms, null, state, [], [], done);
      });
    });
  });

  describe('startInstructionsRequest', () => {
    it('dispatches two actions', done => {
      testAction(
        actions.startInstructionsRequest,
        'linux',
        state,
        [],
        [
          { type: 'selectArchitecture', payload: 'linux' },
          { type: 'requestPlatformsInstructions' },
        ],
        done,
      );
    });
  });
});

import MockAdapter from 'axios-mock-adapter';
import {
  setCodequalityEndpoint,
  clearCodequalityPoll,
  stopCodequalityPolling,
  fetchCodequality,
} from 'ee/diffs/store/actions';
import { RETRY_DELAY } from 'ee/diffs/store/constants';
import * as types from 'ee/diffs/store/mutation_types';
import testAction from 'helpers/vuex_action_helper';
import waitForPromises from 'helpers/wait_for_promises';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import Poll from '~/lib/utils/poll';

jest.mock('~/flash');

describe('EE DiffsStoreActions', () => {
  describe('setCodequalityEndpoint', () => {
    it('should set given endpoint', (done) => {
      const endpoint = '/codequality_mr_diff.json';

      testAction(
        setCodequalityEndpoint,
        { endpoint },
        {},
        [{ type: types.SET_CODEQUALITY_ENDPOINT, payload: { endpoint } }],
        [],
        done,
      );
    });
  });

  describe('fetchCodequality', () => {
    let mock;
    const endpointCodequality = '/codequality_mr_diff.json';

    beforeEach(() => {
      mock = new MockAdapter(axios);
    });

    afterEach(() => {
      stopCodequalityPolling();
      clearCodequalityPoll();
    });

    it('should commit SET_CODEQUALITY_DATA with received response and stop polling', (done) => {
      const data = {
        files: { 'app.js': [{ line: 1, description: 'Unexpected alert.', severity: 'minor' }] },
      };

      mock.onGet(endpointCodequality).reply(200, { data });

      testAction(
        fetchCodequality,
        {},
        { endpointCodequality },
        [{ type: types.SET_CODEQUALITY_DATA, payload: { data } }],
        [{ type: 'stopCodequalityPolling' }],
        done,
      );
    });

    describe('with 400 status response', () => {
      let pollDelayedRequest;
      let pollStop;

      beforeEach(() => {
        pollDelayedRequest = jest.spyOn(Poll.prototype, 'makeDelayedRequest');
        pollStop = jest.spyOn(Poll.prototype, 'stop');

        mock.onGet(endpointCodequality).reply(400);
      });

      it('should not show a flash message', (done) => {
        testAction(fetchCodequality, {}, { endpointCodequality }, [], [], () => {
          expect(createFlash).not.toHaveBeenCalled();
          done();
        });
      });

      it('should retry five times with a delay, then stop polling', (done) => {
        testAction(fetchCodequality, {}, { endpointCodequality }, [], [], () => {
          expect(pollDelayedRequest).toHaveBeenCalledTimes(1);
          expect(pollStop).toHaveBeenCalledTimes(0);

          jest.advanceTimersByTime(RETRY_DELAY);

          waitForPromises()
            .then(() => {
              expect(pollDelayedRequest).toHaveBeenCalledTimes(2);

              jest.advanceTimersByTime(RETRY_DELAY);
            })
            .then(() => waitForPromises())
            .then(() => jest.advanceTimersByTime(RETRY_DELAY))
            .then(() => waitForPromises())
            .then(() => jest.advanceTimersByTime(RETRY_DELAY))
            .then(() => waitForPromises())
            .then(() => {
              expect(pollDelayedRequest).toHaveBeenCalledTimes(5);

              jest.advanceTimersByTime(RETRY_DELAY);
            })
            .then(() => waitForPromises())
            .then(() => {
              expect(pollStop).toHaveBeenCalledTimes(1);
            })
            .then(done)
            .catch(done.fail);
        });
      });
    });

    it('with unexpected error should stop polling and show a flash message', (done) => {
      mock.onGet(endpointCodequality).reply(500);

      testAction(
        fetchCodequality,
        {},
        { endpointCodequality },
        [],
        [{ type: 'stopCodequalityPolling' }],
        () => {
          expect(createFlash).toHaveBeenCalledTimes(1);
          expect(createFlash).toHaveBeenCalledWith({
            message: 'An unexpected error occurred while loading the code quality diff.',
          });
          done();
        },
      );
    });
  });
});

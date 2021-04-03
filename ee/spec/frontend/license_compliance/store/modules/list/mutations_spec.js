import { REPORT_STATUS } from 'ee/license_compliance/store/modules/list/constants';
import * as types from 'ee/license_compliance/store/modules/list/mutation_types';
import mutations from 'ee/license_compliance/store/modules/list/mutations';
import getInitialState from 'ee/license_compliance/store/modules/list/state';
import { toLicenseObject } from 'ee/license_compliance/utils/mappers';
import { TEST_HOST } from 'helpers/test_constants';

describe('Licenses mutations', () => {
  let state;

  beforeEach(() => {
    state = getInitialState();
  });

  describe(types.SET_LICENSES_ENDPOINT, () => {
    it('sets the endpoint and download endpoint', () => {
      mutations[types.SET_LICENSES_ENDPOINT](state, TEST_HOST);

      expect(state.endpoint).toBe(TEST_HOST);
    });
  });

  describe(types.REQUEST_LICENSES, () => {
    beforeEach(() => {
      mutations[types.REQUEST_LICENSES](state);
    });

    it('correctly mutates the state', () => {
      expect(state.isLoading).toBe(true);
      expect(state.errorLoading).toBe(false);
    });
  });

  describe(types.RECEIVE_LICENSES_SUCCESS, () => {
    const licenses = [{ id: 1 }, { id: 2 }];
    const pageInfo = {};
    const reportInfo = {
      status: REPORT_STATUS.jobFailed,
      job_path: 'foo',
    };

    beforeEach(() => {
      mutations[types.RECEIVE_LICENSES_SUCCESS](state, { licenses, reportInfo, pageInfo });
    });

    it('correctly mutates the state', () => {
      expect(state.isLoading).toBe(false);
      expect(state.errorLoading).toBe(false);
      expect(state.licenses).toEqual(licenses.map(toLicenseObject));
      expect(state.pageInfo).toBe(pageInfo);
      expect(state.initialized).toBe(true);
      expect(state.reportInfo).toEqual({
        status: REPORT_STATUS.jobFailed,
        jobPath: 'foo',
      });
    });
  });

  describe(types.RECEIVE_LICENSES_ERROR, () => {
    beforeEach(() => {
      mutations[types.RECEIVE_LICENSES_ERROR](state);
    });

    it('correctly mutates the state', () => {
      expect(state.isLoading).toBe(false);
      expect(state.errorLoading).toBe(true);
      expect(state.licenses).toEqual([]);
      expect(state.pageInfo).toEqual({ total: 0 });
      expect(state.initialized).toBe(true);
      expect(state.reportInfo).toEqual({
        generatedAt: '',
        status: REPORT_STATUS.ok,
        jobPath: '',
      });
    });
  });
});

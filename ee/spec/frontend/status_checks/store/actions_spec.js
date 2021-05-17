import MockAdapter from 'axios-mock-adapter';
import * as actions from 'ee/status_checks/store/actions';
import * as types from 'ee/status_checks/store/mutation_types';
import axios from '~/lib/utils/axios_utils';
import httpStatusCodes from '~/lib/utils/http_status';

const statusChecksPath = '/api/v4/projects/1/external_approval_rules';
const commit = jest.fn();
let mockAxios;

describe('Status checks actions', () => {
  beforeEach(() => {
    mockAxios = new MockAdapter(axios);
  });

  afterEach(() => {
    mockAxios.restore();
  });

  it(`should commit the API response`, async () => {
    const data = [{ name: 'Foo' }, { name: 'Bar' }];

    mockAxios.onGet(statusChecksPath).replyOnce(httpStatusCodes.OK, data);

    await actions.fetchStatusChecks({ commit }, { statusChecksPath });

    expect(commit).toHaveBeenCalledWith(types.SET_LOADING, true);
    expect(commit).toHaveBeenCalledWith(types.SET_STATUS_CHECKS, data);
    expect(commit).toHaveBeenCalledWith(types.SET_LOADING, false);
  });

  it('should error with a failed API response', async () => {
    mockAxios.onGet(statusChecksPath).networkError();

    await expect(actions.fetchStatusChecks({ commit }, { statusChecksPath })).rejects.toThrow(
      new Error('Network Error'),
    );
    expect(commit).toHaveBeenCalledWith(types.SET_LOADING, true);
    expect(commit).toHaveBeenCalledTimes(1);
  });
});

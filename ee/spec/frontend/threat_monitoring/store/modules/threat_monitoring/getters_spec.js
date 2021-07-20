import { INVALID_CURRENT_ENVIRONMENT_NAME } from 'ee/threat_monitoring/constants';
import * as getters from 'ee/threat_monitoring/store/modules/threat_monitoring/getters';
import createState from 'ee/threat_monitoring/store/modules/threat_monitoring/state';

describe('threatMonitoring module getters', () => {
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe('currentEnvironment', () => {
    beforeEach(() => {
      state.environments = [{ id: 1 }, { id: 2 }];
    });

    it('returns the current environment given a valid ID', () => {
      state.currentEnvironmentId = 2;

      expect(getters.currentEnvironment(state)).toEqual({ id: 2 });
    });

    it('returns undefined if the environment can not be found', () => {
      state.currentEnvironmentId = 3;

      expect(getters.currentEnvironment(state)).toBe(undefined);
    });
  });

  describe.each`
    context                            | currentEnvironmentId | environments                                                         | expectedName                        | expectedGid
    ${'no environments'}               | ${1}                 | ${[]}                                                                | ${INVALID_CURRENT_ENVIRONMENT_NAME} | ${undefined}
    ${'a non-existent environment id'} | ${2}                 | ${[{ id: 1 }]}                                                       | ${INVALID_CURRENT_ENVIRONMENT_NAME} | ${undefined}
    ${'an existing environment id'}    | ${3}                 | ${[{ id: 3, name: 'foo', global_id: 'gid://gitlab/Environment/3' }]} | ${'foo'}                            | ${'gid://gitlab/Environment/3'}
  `('given $context', ({ currentEnvironmentId, environments, expectedName, expectedGid }) => {
    let mockedGetters;

    beforeEach(() => {
      state.currentEnvironmentId = currentEnvironmentId;
      state.environments = environments;
      mockedGetters = {
        currentEnvironment: {
          id: currentEnvironmentId,
          global_id: expectedGid,
          name: expectedName,
        },
      };
    });

    describe('currentEnvironmentName', () => {
      it('returns the expected name', () => {
        expect(getters.currentEnvironmentName(state, mockedGetters)).toBe(expectedName);
      });
    });

    describe('currentEnvironmentGid', () => {
      it('returns the expected global ID', () => {
        expect(getters.currentEnvironmentGid(state, mockedGetters)).toBe(expectedGid);
      });
    });
  });
});

import * as getters from '~/search/store/getters';
import createState from '~/search/store/state';
import { MOCK_QUERY } from '../mock_data';

describe('Global Search Store Getters', () => {
  let state;

  beforeEach(() => {
    state = createState({ query: MOCK_QUERY });
  });

  describe.each`
    fetchingGroups | fetchingFrequentGroups | loadingGroups
    ${false}       | ${false}               | ${false}
    ${false}       | ${true}                | ${true}
    ${true}        | ${false}               | ${true}
    ${true}        | ${true}                | ${true}
  `('loadingGroups', ({ fetchingGroups, fetchingFrequentGroups, loadingGroups }) => {
    beforeEach(() => {
      state.fetchingGroups = fetchingGroups;
      state.fetchingFrequentGroups = fetchingFrequentGroups;
    });

    it(`returns ${loadingGroups} when fetchingGroups is ${fetchingGroups} and fetchingFrequentGroups is ${fetchingFrequentGroups}`, () => {
      expect(getters.loadingGroups(state)).toBe(loadingGroups);
    });
  });

  describe.each`
    fetchingProjects | fetchingFrequentProjects | loadingProjects
    ${false}         | ${false}                 | ${false}
    ${false}         | ${true}                  | ${true}
    ${true}          | ${false}                 | ${true}
    ${true}          | ${true}                  | ${true}
  `('loadingProjects', ({ fetchingProjects, fetchingFrequentProjects, loadingProjects }) => {
    beforeEach(() => {
      state.fetchingProjects = fetchingProjects;
      state.fetchingFrequentProjects = fetchingFrequentProjects;
    });

    it(`returns ${loadingProjects} when fetchingProjects is ${fetchingProjects} and fetchingFrequentProjects is ${fetchingFrequentProjects}`, () => {
      expect(getters.loadingProjects(state)).toBe(loadingProjects);
    });
  });
});

import * as getters from 'ee/security_dashboard/store/modules/project_selector/getters';
import createState from 'ee/security_dashboard/store/modules/project_selector/state';

describe('project selector module getters', () => {
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe('canAddProjects', () => {
    describe.each`
      isAddingProjects | selectedProjectCount | expected
      ${true}          | ${0}                 | ${false}
      ${true}          | ${1}                 | ${false}
      ${false}         | ${0}                 | ${false}
      ${false}         | ${1}                 | ${true}
    `(
      'given isAddingProjects = $isAddingProjects and $selectedProjectCount selected projects',
      ({ isAddingProjects, selectedProjectCount, expected }) => {
        beforeEach(() => {
          state = {
            ...state,
            isAddingProjects,
            selectedProjects: Array(selectedProjectCount).fill({}),
          };
        });

        it(`returns ${expected}`, () => {
          expect(getters.canAddProjects(state)).toBe(expected);
        });
      },
    );
  });

  describe('isSearchingProjects', () => {
    describe.each`
      searchCount | expected
      ${0}        | ${false}
      ${1}        | ${true}
      ${2}        | ${true}
    `('given searchCount = $searchCount', ({ searchCount, expected }) => {
      beforeEach(() => {
        state = { ...state, searchCount };
      });

      it(`returns ${expected}`, () => {
        expect(getters.isSearchingProjects(state)).toBe(expected);
      });
    });
  });

  describe('isUpdatingProjects', () => {
    describe.each`
      isAddingProjects | isRemovingProject | isLoadingProjects | expected
      ${false}         | ${false}          | ${false}          | ${false}
      ${true}          | ${false}          | ${false}          | ${true}
      ${false}         | ${true}           | ${false}          | ${true}
      ${false}         | ${false}          | ${true}           | ${true}
    `(
      'given isAddingProjects = $isAddingProjects, isRemovingProject = $isRemovingProject, isLoadingProjects = $isLoadingProjects',
      ({ isAddingProjects, isRemovingProject, isLoadingProjects, expected }) => {
        beforeEach(() => {
          state = { ...state, isAddingProjects, isRemovingProject, isLoadingProjects };
        });

        it(`returns ${expected}`, () => {
          expect(getters.isUpdatingProjects(state)).toBe(expected);
        });
      },
    );
  });
});

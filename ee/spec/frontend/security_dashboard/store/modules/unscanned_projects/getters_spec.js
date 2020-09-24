import * as getters from 'ee/security_dashboard/store/modules/unscanned_projects/getters';
import { UNSCANNED_PROJECTS_DATE_RANGES } from 'ee/security_dashboard/store/constants';
import { groupByDateRanges } from 'ee/security_dashboard/store/modules/unscanned_projects/utils';

describe('Unscanned projects getters', () => {
  describe('untestedProjects', () => {
    it('takes an array of projects and returns only projects that have "securityTestsUnconfigured" set to be "true"', () => {
      const projects = [
        { securityTestsUnconfigured: null },
        { securityTestsUnconfigured: true },
        { securityTestsUnconfigured: false },
        { securityTestsUnconfigured: true },
        {},
      ];

      expect(getters.untestedProjects({ projects })).toStrictEqual([projects[1], projects[3]]);
    });
  });

  describe('untestedProjectsCount', () => {
    it('returns the amount of untestedProjects', () => {
      const untestedProjects = [{}, {}, {}];

      expect(getters.untestedProjectsCount({}, { untestedProjects })).toBe(untestedProjects.length);
    });
  });

  describe('outdatedProjects', () => {
    it('groups the given projects by date ranges', () => {
      const mockedDate = new Date(2015, 4, 15);
      jest.spyOn(global.Date, 'now').mockImplementation(() => mockedDate.valueOf());

      const projects = [
        {
          description: '5 days ago',
          securityTestsLastSuccessfulRun: '2015-05-10T10:00:00.0000',
        },
        {
          description: '6 days ago',
          securityTestsLastSuccessfulRun: '2015-05-09T10:00:00.0000',
        },
        {
          description: '30 days ago',
          securityTestsLastSuccessfulRun: '2015-04-15T10:00:00.0000',
        },
        {
          description: '60 days ago',
          securityTestsLastSuccessfulRun: '2015-03-16T10:00:00',
        },
        {
          description: 'more than 60 days ago',
          securityTestsLastSuccessfulRun: '2012-03-16T10:00:00',
        },
      ];

      const result = getters.outdatedProjects({ projects });

      expect(result).toHaveLength(3);
      expect(result).toEqual(
        groupByDateRanges({
          ranges: UNSCANNED_PROJECTS_DATE_RANGES,
          dateFn: x => x.securityTestsLastSuccessfulRun,
          projects,
        }),
      );
    });
  });

  describe('outdatedProjectsCount', () => {
    it('returns the amount of outdated projects', () => {
      const dateRangeOne = [{}, {}];
      const dateRangeTwo = [{}];
      const outdatedProjects = [{ projects: dateRangeOne }, { projects: dateRangeTwo }];

      expect(getters.outdatedProjectsCount({}, { outdatedProjects })).toBe(
        dateRangeOne.length + dateRangeTwo.length,
      );
    });
  });
});

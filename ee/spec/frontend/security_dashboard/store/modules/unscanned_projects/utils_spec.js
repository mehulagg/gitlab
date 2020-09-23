import { groupByDateRanges } from 'ee/security_dashboard/store/modules/unscanned_projects/utils';

describe('Project scanning store utils', () => {
  describe('groupByDayRanges', () => {
    beforeEach(() => {
      const mockedDate = new Date(2015, 4, 15);
      jest.spyOn(global.Date, 'now').mockImplementation(() => mockedDate.valueOf());
    });

    afterEach(() => {
      jest.clearAllMocks();
    });

    const ranges = [
      { fromDay: 5, toDay: 15, description: '5 days or older' },
      { fromDay: 30, toDay: 60, description: '30 days or older' },
      { fromDay: 60, toDay: Infinity, description: '60 days or older' },
    ];

    it('groups an array of projects into day-ranges, based on when they were last updated', () => {
      const projects = [
        {
          description: '5 days ago',
          lastUpdated: '2015-05-10T10:00:00.0000',
        },
        {
          description: '6 days ago',
          lastUpdated: '2015-05-09T10:00:00.0000',
        },
        {
          description: '30 days ago',
          lastUpdated: '2015-04-15T10:00:00.0000',
        },
        {
          description: '60 days ago',
          lastUpdated: '2015-03-16T10:00:00',
        },
        {
          description: 'more than 60 days ago',
          lastUpdated: '2012-03-16T10:00:00',
        },
      ];

      const groups = groupByDateRanges({
        ranges,
        dateFn: x => x.lastUpdated,
        projects,
      });

      expect(groups[0].projects).toEqual([projects[0], projects[1]]);
      expect(groups[1].projects).toEqual([projects[2]]);
      expect(groups[2].projects).toEqual([projects[3], projects[4]]);
    });

    it('ignores projects that do not match any given group', () => {
      const projectWithoutMatchingGroup = {
        description: '4 days ago',
        lastUpdated: '2015-05-11T10:00:00.0000',
      };

      const projectWithMatchingGroup = {
        description: '6 days ago',
        lastUpdated: '2015-05-09T10:00:00.0000',
      };

      const projects = [projectWithMatchingGroup, projectWithoutMatchingGroup];

      const groups = groupByDateRanges({
        ranges,
        dateFn: x => x.lastUpdated,
        projects,
      });

      expect(groups).toHaveLength(1);
      expect(groups[0].projects).toEqual([projectWithMatchingGroup]);
    });

    it('ignores projects that do not contain valid time values', () => {
      const projectsWithoutTimeStamp = [
        {
          description: 'No timestamp prop',
        },
        {
          description: 'No timestamp prop',
          lastUpdated: 'foo',
        },
        {
          description: 'No timestamp prop',
          lastUpdated: false,
        },
      ];

      const groups = groupByDateRanges({
        ranges,
        dateFn: x => x.lastUpdated,
        projects: projectsWithoutTimeStamp,
      });

      expect(groups).toHaveLength(0);
    });
  });
});

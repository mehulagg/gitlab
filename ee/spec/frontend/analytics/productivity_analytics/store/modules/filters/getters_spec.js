import createState from 'ee/analytics/productivity_analytics/store/modules/filters/state';
import * as getters from 'ee/analytics/productivity_analytics/store/modules/filters/getters';
import { chartKeys } from 'ee/analytics/productivity_analytics/constants';

describe('Productivity analytics filter getters', () => {
  let state;
  const groupNamespace = 'gitlab-org';
  const projectPath = 'gitlab-org/gitlab-test';
  const authorUsername = 'root';
  const milestoneTitle = 'foo';
  const labelName = ['labelxyz'];

  beforeEach(() => {
    state = createState();
  });

  describe('getCommonFilterParams', () => {
    const startDate = new Date('2019-09-01');
    const endDate = new Date('2019-09-07');

    beforeEach(() => {
      state = {
        groupNamespace,
        projectPath,
        authorUsername,
        milestoneTitle,
        labelName,
        startDate,
        endDate,
      };
    });

    describe('when chart is not scatterplot', () => {
      it('returns an object with common filter params', () => {
        const expected = {
          author_username: 'root',
          group_id: 'gitlab-org',
          label_name: ['labelxyz'],
          merged_after: '2019-09-01T00:00:00Z',
          merged_before: '2019-09-07T23:59:59Z',
          milestone_title: 'foo',
          project_id: 'gitlab-org/gitlab-test',
        };

        const result = getters.getCommonFilterParams(state)(chartKeys.main);

        expect(result).toEqual(expected);
      });
    });

    describe('when chart is scatterplot', () => {
      it('returns an object with common filter params and subtracts 30 days from the merged_after date', () => {
        const mergedAfter = '2019-08-02';
        const expected = {
          author_username: 'root',
          group_id: 'gitlab-org',
          label_name: ['labelxyz'],
          merged_after: `${mergedAfter}T00:00:00Z`,
          merged_before: '2019-09-07T23:59:59Z',
          milestone_title: 'foo',
          project_id: 'gitlab-org/gitlab-test',
        };

        const mockGetters = {
          scatterplotStartDate: new Date(mergedAfter),
        };

        const result = getters.getCommonFilterParams(state, mockGetters)(chartKeys.scatterplot);

        expect(result).toEqual(expected);
      });
    });
  });

  describe('scatterplotStartDate', () => {
    beforeEach(() => {
      state = {
        groupNamespace,
        projectPath,
        authorUsername,
        milestoneTitle,
        labelName,
        startDate: new Date('2019-09-01'),
        endDate: new Date('2019-09-10'),
      };
    });

    describe('when a minDate exists', () => {
      it('returns the minDate when the startDate (minus 30 days) is before to the minDate', () => {
        const minDate = new Date('2019-08-15');
        state.minDate = minDate;

        const result = getters.scatterplotStartDate(state);

        expect(result).toBe(minDate);
      });

      it('returns a computed date when the startDate (minus 30 days) is after to the minDate', () => {
        const minDate = new Date('2019-07-01');
        state.minDate = minDate;

        const result = getters.scatterplotStartDate(state);

        expect(result).toEqual(new Date('2019-08-02'));
      });
    });

    describe('when no minDate exists', () => {
      it('returns the computed date, i.e., startDate minus 30 days', () => {
        const result = getters.scatterplotStartDate(state);

        expect(result).toEqual(new Date('2019-08-02'));
      });
    });
  });
});

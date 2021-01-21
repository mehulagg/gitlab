import { getDayDifference, isValidDate } from '~/lib/utils/datetime_utility';

/**
 * Checks if a given number of days is within a date range
 *
 * @param daysInPast {number}
 * @returns {function({fromDay: Number, toDay: Number}): boolean}
 */
const isWithinDateRange = (daysInPast) => ({ fromDay, toDay }) =>
  daysInPast >= fromDay && daysInPast < toDay;

/**
 * Adds an empty 'projects' array to each item of a given array
 *
 * @param ranges {*}[]
 * @returns {{projects: []}}[]
 */
const withEmptyProjectsArray = (ranges) => ranges.map((range) => ({ ...range, projects: [] }));

/**
 * Checks if a given group-object has any projects
 *
 * @param group {{ projects: [] }}
 * @returns {boolean}
 */
const hasProjects = (group) => group.projects.length > 0;

/**
 * Takes an array of objects and groups them based on the given ranges
 *
 * @param ranges {*}[]
 * @param dateFn {Function}
 * @param projects {*}[]
 * @returns {*}[]
 */
export const groupByDateRanges = ({ ranges = [], dateFn = () => {}, projects = [] }) => {
  const today = new Date(Date.now());

  return projects
    .reduce((groups, currentProject) => {
      const timeString = dateFn(currentProject);
      const pastDate = new Date(timeString);

      if (!isValidDate(pastDate) || !timeString) {
        return groups;
      }

      const numDaysInPast = getDayDifference(pastDate, today);

      const matchingGroup = groups.find(isWithinDateRange(numDaysInPast));

      if (matchingGroup) {
        matchingGroup.projects.push(currentProject);
      }

      return groups;
    }, withEmptyProjectsArray(ranges))
    .filter(hasProjects);
};

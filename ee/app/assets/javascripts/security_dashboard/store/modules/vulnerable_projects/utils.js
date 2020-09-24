import { severityLevels } from './constants';

/**
 * Returns the count of a given severity level on a given project
 *
 * @param project
 * @param severityLevel
 * @returns {*|number}
 */
export const vulnerabilityCount = (project, severityLevel) =>
  project[`${severityLevel}VulnerabilityCount`] || 0;

/**
 * Returns "true" if a given project has at least one vulnerability with the given level, otherwise "false"
 *
 * @param project
 * @returns {function(*=): boolean}
 */
export const hasVulnerabilityWithSeverityLevel = project => severityLevel =>
  vulnerabilityCount(project, severityLevel) > 0;

/**
 * Returns the name and count of a project's most severe vulnerability
 *
 * @param severityLevelsOrderedBySeverity
 * @param project
 * @returns {{level: *, count: *}}
 */
export const mostSevereVulnerability = (severityLevelsOrderedBySeverity, project) => {
  const level =
    severityLevelsOrderedBySeverity.find(hasVulnerabilityWithSeverityLevel(project)) ||
    severityLevels.NONE;
  const count = vulnerabilityCount(project, level) || null;

  return {
    level,
    count,
  };
};

/**
 * Takes a project object and adds a property 'mostSevereVulnerability' that contains the 'level'
 * and count of the given project's most severe vulnerability
 *
 * @param severityLevelsInOrder
 * @returns {function(*=): {mostSevereVulnerability: *}}
 */
export const addMostSevereVulnerabilityInformation = severityLevelsInOrder => project => ({
  ...project,
  mostSevereVulnerability: mostSevereVulnerability(severityLevelsInOrder, project),
});

/**
 * Returns an array of projects that match the given severity group
 *
 * @param projects
 * @param group
 * @returns {*}
 */
export const projectsForSeverityGroup = (projects, group) =>
  projects.filter(({ mostSevereVulnerability: { level } }) => group.severityLevels.includes(level));

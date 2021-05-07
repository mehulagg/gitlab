import { SEVERITY_GROUPS, SEVERITY_LEVELS_ORDERED_BY_SEVERITY } from './constants';
import { projectsForSeverityGroup, addMostSevereVulnerabilityInformation } from './utils';

export const severityGroups = ({ projects }) => {
  // add data about it's most severe vulnerability to each project
  const projectsWithSeverityInformation = projects.map(
    addMostSevereVulnerabilityInformation(SEVERITY_LEVELS_ORDERED_BY_SEVERITY),
  );

  // return an array of severity groups, each containing an array of projects match the groups criteria
  return SEVERITY_GROUPS.map((severityGroup) => ({
    ...severityGroup,
    projects: projectsForSeverityGroup(projectsWithSeverityInformation, severityGroup),
  }));
};

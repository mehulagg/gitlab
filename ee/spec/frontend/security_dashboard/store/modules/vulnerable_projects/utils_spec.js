import {
  addMostSevereVulnerabilityInformation,
  hasVulnerabilityWithSeverityLevel,
  mostSevereVulnerability,
  projectsForSeverityGroup,
  vulnerabilityCount,
} from 'ee/security_dashboard/store/modules/vulnerable_projects/utils';

import { createProjectWithOneVulnerability, createProjectWithVulnerabilities } from './mock_data';

describe('Vulnerable Projects store utils', () => {
  describe('addMostSevereVulnerabilityInformation', () => {
    it.each(['critical', 'medium', 'high'])(
      'takes a project and adds a property containing information about its most severe vulnerability',
      severityLevel => {
        const mockProject = createProjectWithOneVulnerability(severityLevel);
        const mockSeverityLevelsInOrder = [severityLevel, 'foo', 'bar'];

        expect(
          addMostSevereVulnerabilityInformation(mockSeverityLevelsInOrder)(mockProject),
        ).toEqual({
          ...mockProject,
          mostSevereVulnerability: {
            level: severityLevel,
            count: 1,
          },
        });
      },
    );
  });

  describe('hasAtLeastOneVulnerabilityWithSeverityLevel', () => {
    it('returns true if the given project has at least one vulnerability of the given severity level', () => {
      const project = createProjectWithOneVulnerability('critical');

      expect(hasVulnerabilityWithSeverityLevel(project)('critical')).toBe(true);
    });

    it.each(['high', 'medium', 'low'])(
      'returns false if the given project does not contain at least one vulnerability of the given severity level',
      severityLevel => {
        const project = createProjectWithOneVulnerability(severityLevel);

        expect(hasVulnerabilityWithSeverityLevel(project)('critical')).toBe(false);
      },
    );
  });

  describe('mostSevereVulnerability', () => {
    it.each`
      severityLevelsInProjects                            | mostSevereLevel
      ${['critical', 'high', 'unknown', 'medium', 'low']} | ${'critical'}
      ${['high', 'unknown', 'medium', 'low']}             | ${'high'}
      ${['unknown', 'medium', 'low']}                     | ${'unknown'}
      ${['medium', 'low']}                                | ${'medium'}
      ${['low']}                                          | ${'low'}
      ${['none']}                                         | ${'none'}
    `(
      'given $severityLevelsInProjects returns an object containing the name and type of the most severe vulnerability',
      ({ severityLevelsInProjects, mostSevereLevel }) => {
        const severityLevelsInOrder = ['critical', 'high', 'unknown', 'medium', 'low', 'none'];

        const mockProject = createProjectWithOneVulnerability(...severityLevelsInProjects);

        expect(mostSevereVulnerability(severityLevelsInOrder, mockProject)).toEqual({
          level: mostSevereLevel,
          count: 1,
        });
      },
    );
  });

  describe('vulnerabilityCount', () => {
    it.each`
      severityLevel | count
      ${'critical'} | ${1}
      ${'high'}     | ${2}
      ${'medium'}   | ${3}
      ${'low'}      | ${4}
      ${'unknown'}  | ${5}
    `(
      "returns the correct count for '$severityLevel' vulnerabilities",
      ({ severityLevel, count }) => {
        const project = createProjectWithVulnerabilities(count)(severityLevel);

        expect(vulnerabilityCount(project, severityLevel)).toBe(count);
      },
    );
  });

  describe('projectsForSeverityGroup', () => {
    it.each`
      severityLevelsForGroup | expectedProjectsInGroup
      ${['critical']}        | ${['A']}
      ${['high', 'unknown']} | ${['B', 'C']}
      ${['low']}             | ${['D']}
    `(
      'returns all projects that fall under the given severity group',
      ({ severityLevelsForGroup, expectedProjectsInGroup }) => {
        const mockProjects = {
          A: { mostSevereVulnerability: { level: 'critical' } },
          B: { mostSevereVulnerability: { level: 'high' } },
          C: { mostSevereVulnerability: { level: 'unknown' } },
          D: { mostSevereVulnerability: { level: 'low' } },
        };

        const mockGroup = { severityLevels: severityLevelsForGroup };

        expect(projectsForSeverityGroup(Object.values(mockProjects), mockGroup)).toStrictEqual(
          expectedProjectsInGroup.map(project => mockProjects[project]),
        );
      },
    );
  });
});

import * as getters from 'ee/security_dashboard/store/modules/vulnerable_projects/getters';

import {
  createProjectWithOneVulnerability,
  createProjectWithZeroVulnerabilities,
} from './mock_data';

describe('vulnerable projects module getters', () => {
  describe('severityGroups', () => {
    it('takes an array of projects containing vulnerability data and groups them by severity level', () => {
      const mockProjects = [
        createProjectWithOneVulnerability('critical'),
        createProjectWithOneVulnerability('high'),
        createProjectWithOneVulnerability('unknown'),
        createProjectWithOneVulnerability('medium'),
        createProjectWithOneVulnerability('low'),
        createProjectWithZeroVulnerabilities(),
      ];

      const state = { projects: mockProjects };

      const projectsGroupedBySeverityLevel = getters.severityGroups(state);

      expect(projectsGroupedBySeverityLevel).toMatchSnapshot();
    });
  });
});

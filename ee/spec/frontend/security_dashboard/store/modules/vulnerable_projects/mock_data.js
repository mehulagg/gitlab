export const createProjectWithZeroVulnerabilities = () => ({
  id: 'id',
  fullName: 'full_name',
  fullPath: 'full_path',
  criticalVulnerabilityCount: 0,
  highVulnerabilityCount: 0,
  mediumVulnerabilityCount: 0,
  lowVulnerabilityCount: 0,
  unknownVulnerabilityCount: 0,
});

// in the future this will be replaced by generated fixtures
// see https://gitlab.com/gitlab-org/gitlab/merge_requests/20892#note_253602093
export const createProjectWithVulnerabilities = count => (...severityLevels) => ({
  ...createProjectWithZeroVulnerabilities(),
  ...(severityLevels
    ? severityLevels.reduce(
        (levels, level) => ({
          ...levels,
          [`${level}VulnerabilityCount`]: count,
        }),
        {},
      )
    : {}),
});

export const createProjectWithOneVulnerability = createProjectWithVulnerabilities(1);

export const getProjectIdQueryParams = projects =>
  `project_ids=${projects.map(project => project.id).join(',')}`;

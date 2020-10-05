import dateFormat from 'dateformat';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import { dateFormats } from './constants';

export const toYmd = date => dateFormat(date, dateFormats.isoDate);

export default {
  toYmd,
};

export const formattedDate = d => dateFormat(d, dateFormats.defaultDate);

/**
 * Creates a group object from a dataset. Returns null if no groupId is present.
 *
 * @param {Object} dataset - The container's dataset
 * @returns {Object} - A group object
 */
export const buildGroupFromDataset = dataset => {
  const { groupId, groupName, groupFullPath, groupAvatarUrl, groupParentId } = dataset;

  if (groupId) {
    return {
      id: Number(groupId),
      name: groupName,
      full_path: groupFullPath,
      avatar_url: groupAvatarUrl,
      parent_id: groupParentId,
    };
  }

  return null;
};

/**
 * Creates a project object from a dataset. Returns null if no projectId is present.
 *
 * @param {Object} dataset - The container's dataset
 * @returns {Object} - A project object
 */
export const buildProjectFromDataset = dataset => {
  const { projectId, projectName, projectPathWithNamespace, projectAvatarUrl } = dataset;

  if (projectId) {
    return {
      id: Number(projectId),
      name: projectName,
      path_with_namespace: projectPathWithNamespace,
      avatar_url: projectAvatarUrl,
    };
  }

  return null;
};

/**
 * Creates an array of project objects from a json string. Returns null if no projects are present.
 *
 * @param {String} data - JSON encoded array of projects
 * @returns {Array} - An array of project objects
 */
const buildProjectsFromJSON = (projects = []) => {
  if (!projects.length) return [];
  return JSON.parse(projects);
};

/**
 * Builds the initial data object for cycle analytics with data loaded from the backend
 *
 * @param {Object} dataset - dataset object paseed to the frontend via data-* properties
 * @returns {Object} - The initial data to load the app with
 */
export const buildCycleAnalyticsInitialData = ({
  groupId = null,
  createdBefore = null,
  createdAfter = null,
  projects = null,
  groupName = null,
  groupFullPath = null,
  groupParentId = null,
  groupAvatarUrl = null,
  labelsPath = '',
  milestonesPath = '',
} = {}) => ({
  group: groupId
    ? convertObjectPropsToCamelCase(
        buildGroupFromDataset({
          groupId,
          groupName,
          groupFullPath,
          groupAvatarUrl,
          groupParentId,
        }),
      )
    : null,
  createdBefore: createdBefore ? new Date(createdBefore) : null,
  createdAfter: createdAfter ? new Date(createdAfter) : null,
  selectedProjects: projects
    ? buildProjectsFromJSON(projects).map(convertObjectPropsToCamelCase)
    : [],
  labelsPath,
  milestonesPath,
});

export const filterBySearchTerm = (data = [], searchTerm = '', filterByKey = 'name') => {
  if (!searchTerm?.length) return data;
  return data.filter(item => item[filterByKey].toLowerCase().includes(searchTerm.toLowerCase()));
};

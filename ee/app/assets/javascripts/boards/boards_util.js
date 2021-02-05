import { urlParamsToObject } from '~/lib/utils/common_utils';
import { objectToQuery } from '~/lib/utils/url_utility';
import {
  IterationFilterType,
  IterationIDs,
  MilestoneFilterType,
  MilestoneIDs,
  WeightFilterType,
  WeightIDs,
} from './constants';

export function getMilestone({ milestone }) {
  return milestone || null;
}

export function fullEpicId(epicId) {
  return `gid://gitlab/Epic/${epicId}`;
}

export function fullMilestoneId(milestoneId) {
  return `gid://gitlab/Milestone/${milestoneId}`;
}

export function fullUserId(userId) {
  return `gid://gitlab/User/${userId}`;
}

export function transformBoardConfig(boardConfig) {
  const updatedBoardConfig = {};
  const passedFilterParams = urlParamsToObject(window.location.search);
  const updateScopeObject = (key, value = '') => {
    if (value === null || value === '') return;
    // Comparing with value string because weight can be a number
    if (!passedFilterParams[key] || passedFilterParams[key] !== value.toString()) {
      updatedBoardConfig[key] = value;
    }
  };

  let { milestoneTitle } = boardConfig;
  if (boardConfig.milestoneId === MilestoneIDs.NONE) {
    milestoneTitle = MilestoneFilterType.none;
  }
  if (milestoneTitle) {
    updateScopeObject('milestone_title', milestoneTitle);
  }

  let { iterationTitle } = boardConfig;
  if (boardConfig.iterationId === IterationIDs.NONE) {
    iterationTitle = IterationFilterType.none;
  }

  if (iterationTitle) {
    updateScopeObject('iteration_id', iterationTitle);
  }

  let { weight } = boardConfig;
  if (weight !== WeightIDs.ANY) {
    if (weight === WeightIDs.NONE) {
      weight = WeightFilterType.none;
    }

    updateScopeObject('weight', weight);
  }

  updateScopeObject('assignee_username', boardConfig.assigneeUsername);

  let updatedFilterPath = objectToQuery(updatedBoardConfig);
  const filterPath = updatedFilterPath ? updatedFilterPath.split('&') : [];

  boardConfig.labels.forEach((label) => {
    const labelTitle = encodeURIComponent(label.title);
    const param = `label_name[]=${labelTitle}`;
    const labelIndex = passedFilterParams.label_name?.indexOf(labelTitle);

    if (labelIndex === -1 || labelIndex === undefined) {
      filterPath.push(param);
    }
  });

  updatedFilterPath = filterPath.join('&');
  return updatedFilterPath;
}

export default {
  getMilestone,
  fullEpicId,
  fullMilestoneId,
  fullUserId,
  transformBoardConfig,
};

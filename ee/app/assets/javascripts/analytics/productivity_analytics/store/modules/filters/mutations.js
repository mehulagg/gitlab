import * as types from './mutation_types';

export default {
  [types.SET_INITIAL_DATA](
    state,
    {
      groupNamespace = null,
      projectPath = null,
      authorUsername = null,
      labelName = [],
      milestoneTitle = null,
      mergedAfter,
      mergedBefore,
      minDate,
    },
  ) {
    state.groupNamespace = groupNamespace;
    state.projectPath = projectPath;
    state.authorUsername = authorUsername;
    state.labelName = labelName;
    state.milestoneTitle = milestoneTitle;
    state.startDate = mergedAfter;
    state.endDate = mergedBefore;
    state.minDate = minDate;
  },
  [types.SET_GROUP_NAMESPACE](state, groupNamespace) {
    state.groupNamespace = groupNamespace;
    state.projectPath = null;
    state.authorUsername = null;
    state.labelName = [];
    state.milestoneTitle = null;
  },
  [types.SET_PROJECT_PATH](state, projectPath) {
    state.projectPath = projectPath;
    state.authorUsername = null;
    state.labelName = [];
    state.milestoneTitle = null;
  },
  [types.SET_FILTERS](state, { authorUsername, labelName, milestoneTitle }) {
    state.authorUsername = authorUsername;
    state.labelName = labelName;
    state.milestoneTitle = milestoneTitle;
  },
  [types.SET_DATE_RANGE](state, { startDate, endDate }) {
    state.startDate = startDate;
    state.endDate = endDate;
  },
};

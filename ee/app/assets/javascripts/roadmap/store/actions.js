import { deprecatedCreateFlash as flash } from '~/flash';
import { s__ } from '~/locale';

import * as epicUtils from '../utils/epic_utils';
import * as roadmapItemUtils from '../utils/roadmap_item_utils';
import {
  getEpicsTimeframeRange,
  sortEpics,
  extendTimeframeForPreset,
} from '../utils/roadmap_utils';

import { EXTEND_AS } from '../constants';

import groupEpics from '../queries/groupEpics.query.graphql';
import epicChildEpics from '../queries/epicChildEpics.query.graphql';
import groupMilestones from '../queries/groupMilestones.query.graphql';

import * as types from './mutation_types';

export const setInitialData = ({ commit }, data) => commit(types.SET_INITIAL_DATA, data);

const fetchGroupEpics = (
  { epicIid, fullPath, epicsState, sortedBy, presetType, filterParams, timeframe },
  defaultTimeframe,
) => {
  let query;
  let variables = {
    fullPath,
    state: epicsState,
    sort: sortedBy,
    ...getEpicsTimeframeRange({
      presetType,
      timeframe: defaultTimeframe || timeframe,
    }),
  };

  // When epicIid is present,
  // Roadmap is being accessed from within an Epic,
  // and then we don't need to pass `filterParams`.
  if (epicIid) {
    query = epicChildEpics;
    variables.iid = epicIid;
  } else {
    query = groupEpics;
    variables = {
      ...variables,
      ...filterParams,
    };
  }

  return epicUtils.gqClient
    .query({
      query,
      variables,
    })
    .then(({ data }) => {
      const edges = epicIid
        ? data?.group?.epic?.children?.edges || []
        : data?.group?.epics?.edges || [];

      return epicUtils.extractGroupEpics(edges);
    });
};

export const fetchChildrenEpics = (state, { parentItem }) => {
  const { iid, group } = parentItem;
  const { filterParams, epicsState } = state;

  return epicUtils.gqClient
    .query({
      query: epicChildEpics,
      variables: { iid, fullPath: group?.fullPath, state: epicsState, ...filterParams },
    })
    .then(({ data }) => {
      const edges = data?.group?.epic?.children?.edges || [];
      return epicUtils.extractGroupEpics(edges);
    });
};

export const receiveEpicsSuccess = (
  { commit, dispatch, state },
  { rawEpics, newEpic = false, timeframeExtended },
) => {
  const newEpics = rawEpics
    // Exclude any Epic already present in Roadmap timeline
    .filter((epic) => state.epicIds.indexOf(epic.id) < 0)
    .map((epic) => {
      return {
        ...epic,
        ...roadmapItemUtils.computeDates(epic, state.presetType, state.timeframe),
        isChildEpic: false,
        newEpic,
      };
    })
    // Exclude any Epic that has invalid dates
    .filter((epic) => {
      const hasValidDates = epic.startDate.proxy.getTime() <= epic.dueDate.proxy.getTime();
      return hasValidDates;
    });

  const epicIds = newEpics.map((epic) => epic.id);
  commit(types.UPDATE_EPIC_IDS, epicIds);
  dispatch('initItemChildrenFlags', { epics: newEpics });

  if (timeframeExtended) {
    const updatedEpics = state.epics.concat(newEpics);
    sortEpics(updatedEpics, state.sortedBy);
    commit(types.RECEIVE_EPICS_FOR_TIMEFRAME_SUCCESS, updatedEpics);
  } else {
    commit(types.RECEIVE_EPICS_SUCCESS, newEpics);
  }
};

export const receiveEpicsFailure = ({ commit }) => {
  commit(types.RECEIVE_EPICS_FAILURE);
  flash(s__('GroupRoadmap|Something went wrong while fetching epics'));
};

export const requestChildrenEpics = ({ commit }, { parentItemId }) => {
  commit(types.REQUEST_CHILDREN_EPICS, { parentItemId });
};

export const receiveChildrenSuccess = (
  { commit, dispatch, state },
  { parentItemId, rawChildren },
) => {
  const newEpics = rawChildren
    .map((epic) => {
      return {
        ...epic,
        ...roadmapItemUtils.computeDates(epic, state.presetType, state.timeframe),
        isChildEpic: true,
      };
    })
    // Exclude any Epic that has invalid dates
    .filter((epic) => {
      const hasValidDates = epic.startDate.proxy.getTime() <= epic.dueDate.proxy.getTime();
      return hasValidDates;
    });

  dispatch('expandEpic', {
    parentItemId,
  });
  dispatch('initItemChildrenFlags', { epics: newEpics });
  commit(types.RECEIVE_CHILDREN_SUCCESS, { parentItemId, children: newEpics });
};

export const fetchEpics = ({ state, commit, dispatch }) => {
  commit(types.REQUEST_EPICS);

  fetchGroupEpics(state)
    .then((rawEpics) => {
      dispatch('receiveEpicsSuccess', { rawEpics });
    })
    .catch((e) => {
      console.log(e);
      dispatch('receiveEpicsFailure');
    });
};

export const fetchEpicsForTimeframe = ({ state, commit, dispatch }, { timeframe }) => {
  commit(types.REQUEST_EPICS_FOR_TIMEFRAME);

  return fetchGroupEpics(state, timeframe)
    .then((rawEpics) => {
      dispatch('receiveEpicsSuccess', {
        rawEpics,
        newEpic: true,
        timeframeExtended: true,
      });
    })
    .catch(() => dispatch('receiveEpicsFailure'));
};

/**
 * Adds more EpicItemTimeline cells to the start or end of the roadmap.
 *
 * @param extendAs An EXTEND_AS enum value
 */
export const extendTimeframe = ({ commit, state }, { extendAs }) => {
  const isExtendTypePrepend = extendAs === EXTEND_AS.PREPEND;
  const { presetType, timeframe } = state;
  const timeframeToExtend = extendTimeframeForPreset({
    extendAs,
    presetType,
    initialDate: isExtendTypePrepend
      ? roadmapItemUtils.getTimeframeStartDate(presetType, timeframe)
      : roadmapItemUtils.getTimeframeEndDate(presetType, timeframe),
  });

  if (isExtendTypePrepend) {
    commit(types.PREPEND_TIMEFRAME, timeframeToExtend);
  } else {
    commit(types.APPEND_TIMEFRAME, timeframeToExtend);
  }
};

export const initItemChildrenFlags = ({ commit }, data) =>
  commit(types.INIT_EPIC_CHILDREN_FLAGS, data);

export const expandEpic = ({ commit }, { parentItemId }) =>
  commit(types.EXPAND_EPIC, { parentItemId });
export const collapseEpic = ({ commit }, { parentItemId }) =>
  commit(types.COLLAPSE_EPIC, { parentItemId });

export const toggleEpic = ({ state, dispatch }, { parentItem }) => {
  const parentItemId = parentItem.id;
  if (!state.childrenFlags[parentItemId].itemExpanded) {
    if (!state.childrenEpics[parentItemId]) {
      dispatch('requestChildrenEpics', { parentItemId });
      fetchChildrenEpics(state, { parentItem })
        .then((rawChildren) => {
          dispatch('receiveChildrenSuccess', {
            parentItemId,
            rawChildren,
          });
        })
        .catch(() => dispatch('receiveEpicsFailure'));
    } else {
      dispatch('expandEpic', {
        parentItemId,
      });
    }
  } else {
    dispatch('collapseEpic', {
      parentItemId,
    });
  }
};

/**
 * For epics that have no start or due date, this function updates their start and due dates
 * so that the epic bars get longer to appear infinitely scrolling.
 */
export const refreshEpicDates = ({ commit, state }) => {
  const epics = state.epics.map((epic) => {
    // Update child epic dates too
    let newEpicChildren;
    if (epic.children?.edges?.length > 0) {
      newEpicChildren = {
        ...epic.children,
        edges: epic.children.edges.map((childEpic) => {
          return {
            ...childEpic,
            ...roadmapItemUtils.computeDates(childEpic, state.presetType, state.timeframe),
          };
        }),
      };
    }

    return {
      ...epic,
      ...roadmapItemUtils.computeDates(epic, state.presetType, state.timeframe),
      children: newEpicChildren,
    };
  });

  commit(types.SET_EPICS, epics);
};

export const fetchGroupMilestones = (
  { fullPath, presetType, filterParams, timeframe },
  defaultTimeframe,
) => {
  const query = groupMilestones;
  const variables = {
    fullPath,
    state: 'active',
    ...getEpicsTimeframeRange({
      presetType,
      timeframe: defaultTimeframe || timeframe,
    }),
    includeDescendants: true,
    ...filterParams,
  };

  return epicUtils.gqClient
    .query({
      query,
      variables,
    })
    .then(({ data }) => {
      const { group } = data;

      const edges = (group.milestones && group.milestones.edges) || [];

      return roadmapItemUtils.extractGroupMilestones(edges);
    });
};

export const requestMilestones = ({ commit }) => commit(types.REQUEST_MILESTONES);

export const fetchMilestones = ({ state, dispatch }) => {
  dispatch('requestMilestones');

  return fetchGroupMilestones(state)
    .then((rawMilestones) => {
      dispatch('receiveMilestonesSuccess', { rawMilestones });
    })
    .catch((e) => {
      console.log(e);
      dispatch('receiveMilestonesFailure');
    });
};

export const receiveMilestonesSuccess = (
  { commit, state },
  { rawMilestones, newMilestone = false }, // timeframeExtended
) => {
  const newMilestones = rawMilestones
    // Exclude any Milestone already present in Roadmap timeline
    .filter((milestone) => state.milestoneIds.indexOf(milestone.id) < 0)
    .map((milestone) => {
      return {
        ...milestone,
        ...roadmapItemUtils.computeDates(milestone, state.presetType, state.timeframe),
        newMilestone,
      };
    })
    // Exclude any Milestone that has invalid dates
    .filter((milestone) => {
      const hasValidDates =
        milestone.startDate.proxy.getTime() <= milestone.dueDate.proxy.getTime();
      return hasValidDates;
    });

  const milestoneIds = newMilestones.map((milestone) => milestone.id);
  commit(types.UPDATE_MILESTONE_IDS, milestoneIds);
  commit(types.RECEIVE_MILESTONES_SUCCESS, newMilestones);
};

export const receiveMilestonesFailure = ({ commit }) => {
  commit(types.RECEIVE_MILESTONES_FAILURE);
  flash(s__('GroupRoadmap|Something went wrong while fetching milestones'));
};

export const refreshMilestoneDates = ({ commit, state }) => {
  const milestones = state.milestones.map((milestone) => {
    return {
      ...milestone,
      ...roadmapItemUtils.computeDates(milestone, state.presetType, state.timeframe),
    };
  });

  commit(types.SET_MILESTONES, milestones);
};

export const setBufferSize = ({ commit }, bufferSize) => commit(types.SET_BUFFER_SIZE, bufferSize);

export const setEpicsState = ({ commit }, epicsState) => commit(types.SET_EPICS_STATE, epicsState);

export const setFilterParams = ({ commit }, filterParams) =>
  commit(types.SET_FILTER_PARAMS, filterParams);

export const setSortedBy = ({ commit }, sortedBy) => commit(types.SET_SORTED_BY, sortedBy);

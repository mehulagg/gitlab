import produce from 'immer';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import getShiftTimeUnitWidthQuery from './graphql/queries/get_shift_time_unit_width.query.graphql';
import getTimelineWidthQuery from './graphql/queries/get_timeline_width.query.graphql';

Vue.use(VueApollo);

const resolvers = {
  Mutation: {
    updateShiftTimeUnitWidth: (_, { shiftTimeUnitWidth = 0 }, { cache }) => {
      const sourceData = cache.readQuery({ query: getShiftTimeUnitWidthQuery });
      const data = produce(sourceData, (draftData) => {
        draftData.shiftTimeUnitWidth = shiftTimeUnitWidth;
      });
      cache.writeQuery({ query: getShiftTimeUnitWidthQuery, data });
    },
    updateTimelineWidth: (_, { timelineWidth = 0 }, { cache }) => {
      const sourceData = cache.readQuery({ query: getTimelineWidthQuery });
      const data = produce(sourceData, (draftData) => {
        draftData.timelineWidth = timelineWidth;
      });
      cache.writeQuery({ query: getTimelineWidthQuery, data });
    },
  },
};

export default new VueApollo({
  defaultClient: createDefaultClient(resolvers, {
    cacheConfig: {},
    assumeImmutableResults: true,
  }),
});

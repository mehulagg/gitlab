import Vue from 'vue';
import VueApollo from 'vue-apollo';
import _ from 'underscore';
import createDefaultClient from '~/lib/graphql';

Vue.use(VueApollo);

const createMockDesign = id => ({
  id,
  image: 'http://via.placeholder.com/300',
  name: 'test.jpg',
  commentsCount: 2,
  updatedAt: new Date().toString(),
  __typename: 'Design',
});

export default new VueApollo({
  defaultClient: createDefaultClient({
    defaults: {
      designs: [
        createMockDesign(_.uniqueId()),
        createMockDesign(_.uniqueId()),
        createMockDesign(_.uniqueId()),
        createMockDesign(_.uniqueId()),
        createMockDesign(_.uniqueId()),
      ],
    },
  }),
});

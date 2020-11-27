import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';

Vue.use(VueApollo);

const resolvers = {
  Query: {
    dastSiteValidations: (_, { normalizedTargetUrls }) => {
      return {
        edges: normalizedTargetUrls.map(url => {
          const randNumber = Math.random();
          let validationStatus = 'INPROGRESS_VALIDATION';
          if (randNumber < 0.3) {
            validationStatus = 'PASSED_VALIDATION';
          } else if (randNumber > 0.7) {
            validationStatus = 'FAILED_VALIDATION';
          }
          return {
            node: {
              normalizedTargetUrl: url,
              status: validationStatus,
              __typename: 'DastSiteValidation',
            },
            __typename: 'DastSiteValidationEdge',
          };
        }),
        __typename: 'DastSiteValidations',
      };
    },
  },
};

export default new VueApollo({
  defaultClient: createDefaultClient(resolvers, {
    assumeImmutableResults: true,
  }),
});

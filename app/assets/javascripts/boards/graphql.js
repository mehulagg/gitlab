import { IntrospectionFragmentMatcher } from 'apollo-cache-inmemory';
import createDefaultClient from '~/lib/graphql';
import introspectionQueryResultData from '~/sidebar/fragmentTypes.json';

const fragmentMatcher = new IntrospectionFragmentMatcher({
  introspectionQueryResultData,
});

export default createDefaultClient(
  {},
  {
    cacheConfig: {
      fragmentMatcher,
    },
    assumeImmutableResults: true,
  },
);

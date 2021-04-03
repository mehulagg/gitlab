import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';

Vue.use(VueApollo);

export const resolvers = {
  DastSiteProfile: {
    auth: () => ({
      __typename: 'DastSiteProfileAuth',
      enabled: true,
      url: 'http://test.local/users/sign_in',
      usernameField: 'username',
      passwordField: 'password',
      username: 'root',
    }),
    excludedUrls: () => ['http://test.local/sign_out', 'http://test.local/send_mail'],
    requestHeaders: () => 'log-identifier: dast-active-scan',
  },
};

export default new VueApollo({
  defaultClient: createDefaultClient(resolvers, { assumeImmutableResults: true }),
});

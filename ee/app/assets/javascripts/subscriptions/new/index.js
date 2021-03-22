import Vue from 'vue';
import VueApollo from 'vue-apollo';
import App from './components/app.vue';
import { STEPS } from './constants';
import defaultClient from './graphql';
import createStore from './store';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient,
});

// eslint-disable-next-line @gitlab/require-i18n-strings
const stepList = STEPS.map((id) => ({ __typename: 'Step', id }));
defaultClient.cache.writeData({
  data: {
    stepList,
    activeStep: stepList[0],
  },
});

export default () => {
  const el = document.getElementById('js-new-subscription');
  const store = createStore(el.dataset);

  return new Vue({
    el,
    store,
    apolloProvider,
    components: {
      App,
    },
    render(createElement) {
      return createElement(App);
    },
  });
};

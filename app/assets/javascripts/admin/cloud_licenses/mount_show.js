import Vue from 'vue';
import Vuex from 'vuex';
import CloudLicenseShowApp from './components/app_show.vue';

Vue.use(Vuex);

export default () => {
  const el = document.getElementById('js-show-cloud-license-page');

  return new Vue({
    el,
    render: (h) => h(CloudLicenseShowApp),
  });
};

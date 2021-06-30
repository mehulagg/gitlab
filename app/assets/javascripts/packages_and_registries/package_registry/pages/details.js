import Vue from 'vue';
import { parseBoolean } from '~/lib/utils/common_utils';
import Translate from '~/vue_shared/translate';
import PackagesApp from '../components/details/app.vue';

Vue.use(Translate);

export default () => {
  const el = document.querySelector('#js-vue-packages-detail-new');
  const { canDelete, ...datesetOptions } = el.dataset;

  // eslint-disable-next-line no-new
  new Vue({
    el,
    provide: {
      canDelete: parseBoolean(canDelete),
      titleComponent: 'PackageTitle',
      ...datesetOptions,
    },
    render(createElement) {
      return createElement(PackagesApp);
    },
  });
};

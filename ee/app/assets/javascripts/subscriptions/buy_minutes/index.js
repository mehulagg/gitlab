import Vue from 'vue';
import EnsureData from '~/vue_shared/components/ensure_data.vue';
import App from './components/app.vue';
import { ERROR_FETCHING_DATA_HEADER, ERROR_FETCHING_DATA_DESCRIPTION } from './constants';
import { parseData } from './utils';

export default (el) => {
  const { emptyStateSvgPath, ...dataset } = el.dataset;

  return new Vue({
    el,
    components: {
      EnsureData,
      App,
    },
    render(createElement) {
      return createElement(EnsureData, {
        props: {
          parse: parseData,
          data: dataset,
          shouldLog: false,
          title: ERROR_FETCHING_DATA_HEADER,
          description: ERROR_FETCHING_DATA_DESCRIPTION,
          svgPath: emptyStateSvgPath,
        },
        scopedSlots: {
          app(props) {
            return createElement({ extends: App, provide: props });
          },
        },
      });
    },
  });
};

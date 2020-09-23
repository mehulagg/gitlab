import { historyPushState } from '~/lib/utils/common_utils';
import { setUrlParams } from '~/lib/utils/url_utility';

export default {
  watch: {
    query() {
      historyPushState(setUrlParams(this.query, window.location.href, true));
    },
  },
};

import Api from '~/api';
import { historyPushState } from '~/lib/utils/common_utils';
import { mergeUrlParams } from '~/lib/utils/url_utility';

const DEVOPS_ADOPTION_PANE = 'devops-adoption';
const DEVOPS_ADOPTION_PANE_TAB_CLICK_EVENT = 'i_analytics_dev_ops_adoption';

const tabClickHandler = (e) => {
  const { hash } = e.currentTarget;
  let tab = null;

  if (hash === `#${DEVOPS_ADOPTION_PANE}`) {
    tab = DEVOPS_ADOPTION_PANE;
    Api.trackRedisHllUserEvent(DEVOPS_ADOPTION_PANE_TAB_CLICK_EVENT);
  }

  const newUrl = mergeUrlParams({ tab }, window.location.href);
  historyPushState(newUrl);
};

const initTabs = () => {
  const tabLinks = document.querySelectorAll('.js-devops-tab-item a');

  if (tabLinks.length) {
    tabLinks.forEach((tabLink) => {
      tabLink.addEventListener('click', (e) => tabClickHandler(e));
    });
  }
};

export default initTabs;

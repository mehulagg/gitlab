import Vue from 'vue';
import UserCallout from '~/user_callout';
import ServicePingDisabled from './components/service_ping_disabled.vue';

export default () => {
  // eslint-disable-next-line no-new
  new UserCallout();

  const emptyStateContainer = document.getElementById('js-devops-service-ping-disabled');

  if (!emptyStateContainer) return false;

  const {
    emptyStateSvgPath,
    enableServicePingLink,
    docsLink,
    isAdmin,
  } = emptyStateContainer.dataset;

  return new Vue({
    el: emptyStateContainer,
    provide: {
      isAdmin: Boolean(isAdmin),
      svgPath: emptyStateSvgPath,
      primaryButtonPath: enableServicePingLink,
      docsLink,
    },
    render(h) {
      return h(ServicePingDisabled);
    },
  });
};

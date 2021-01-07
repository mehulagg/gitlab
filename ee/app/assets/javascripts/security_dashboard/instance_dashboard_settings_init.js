import Vue from 'vue';
import apolloProvider from './graphql/provider';
import InstanceSecurityDashboardSettings from './components/first_class_instance_security_dashboard_settings.vue';

export default (el) => {
  if (!el) {
    return null;
  }

  return new Vue({
    el,
    apolloProvider,
    render(createElement) {
      return createElement(InstanceSecurityDashboardSettings);
    },
  });
};

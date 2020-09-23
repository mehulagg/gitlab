import Vue from 'vue';
import SecurityDiscoverApp from 'ee/vue_shared/discover/card_security_discover_app.vue';

export default () => {
  const securityTab = document.getElementById('js-security-discover-app');
  const {
    groupId,
    groupName,
    projectId,
    projectName,
    linkMain,
    linkSecondary,
    linkFeedback,
  } = securityTab.dataset;

  const props = {
    project: {
      id: projectId,
      name: projectName,
    },
    group: {
      id: groupId,
      name: groupName,
    },
    linkMain,
    linkSecondary,
    linkFeedback,
  };

  return new Vue({
    el: securityTab,
    components: {
      SecurityDiscoverApp,
    },
    render(createElement) {
      return createElement('security-discover-app', {
        props,
      });
    },
  });
};

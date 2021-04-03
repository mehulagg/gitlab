import Tracking from '~/tracking';

export default {
  methods: {
    trackUninstallButtonClick: (application) => {
      Tracking.event('k8s_cluster', 'uninstall', {
        label: application,
      });
    },
  },
};

import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { __ } from '~/locale';
import initTree from '~/repository';

export default () => {
  const { router, data } = initTree();

  if (data.pathLocksAvailable) {
    const toggleBtn = document.querySelector('a.js-path-lock');

    if (!toggleBtn) return;

    toggleBtn.addEventListener('click', (e) => {
      e.preventDefault();

      const { dataset } = e.target;
      const message =
        dataset.state === 'lock'
          ? __('Are you sure you want to lock this directory?')
          : __('Are you sure you want to unlock this directory?');

      // eslint-disable-next-line no-alert
      if (!window.confirm(message)) {
        return;
      }

      toggleBtn.setAttribute('disabled', 'disabled');

      axios
        .post(data.pathLocksToggle, {
          path: router.currentRoute.params.path.replace(/^\//, ''),
        })
        .then(() => window.location.reload())
        .catch(() => {
          toggleBtn.removeAttribute('disabled');
          createFlash({
            message: __('An error occurred while initializing path locks'),
          });
        });
    });
  }
};

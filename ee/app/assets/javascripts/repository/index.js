import initTree from '~/repository';
import axios from '~/lib/utils/axios_utils';
import { sprintf, __ } from '~/locale';
import { deprecatedCreateFlash as createFlash } from '~/flash';

export default () => {
  const { router, data } = initTree();

  if (data.pathLocksAvailable) {
    const toggleBtn = document.querySelector('.js-path-lock');

    if (!toggleBtn) return;

    toggleBtn.addEventListener('click', e => {
      e.preventDefault();

      const { dataset } = e.target;
      const message = sprintf(__('Are you sure you want to %{lock_action} this directory?'), {
        lock_action: dataset.state,
      });
      // eslint-disable-next-line no-alert, no-restricted-globals
      if (!confirm(message)) {
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
          createFlash(__('An error occurred while initializing path locks'));
        });
    });
  }
};

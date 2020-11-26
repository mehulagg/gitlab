import { deprecatedCreateFlash as createFlash } from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { __ } from '~/locale';
import initTree from '~/repository';

export default () => {
  const { router, data } = initTree();

  if (data.pathLocksAvailable) {
    const toggleBtn = document.querySelector('.js-path-lock');

    if (!toggleBtn) return;

    toggleBtn.addEventListener('click', e => {
      e.preventDefault();

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

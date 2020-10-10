import $ from 'jquery';
import { deprecatedCreateFlash as flash } from '~/flash';
import { sprintf, __ } from '~/locale';
import axios from '~/lib/utils/axios_utils';

export default function initPathLocks(url, path) {
  $('a.path-lock').on('click', e => {
    e.preventDefault();

    const { dataset } = e.target;
    const message = sprintf(__('Are you sure you want to %{lock_action} %{path}?'), {
      lock_action: dataset.state,
      path,
    });
    // eslint-disable-next-line no-alert, no-restricted-globals
    if (!confirm(message)) {
      return;
    }

    axios
      .post(url, {
        path,
      })
      .then(() => {
        window.location.reload();
      })
      .catch(() => flash(__('An error occurred while initializing path locks')));
  });
}

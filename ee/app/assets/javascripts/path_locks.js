import $ from 'jquery';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { sprintf, __ } from '~/locale';

export default function initPathLocks(url, path) {
  $('a.path-lock').on('click', (e) => {
    e.preventDefault();

    const { dataset } = e.target;
    const message =
      dataset.state === 'lock'
        ? __('Are you sure you want to lock %{path}?')
        : __('Are you sure you want to unlock %{path}?');

    // eslint-disable-next-line no-alert
    if (!window.confirm(sprintf(message, { path }))) {
      return;
    }

    axios
      .post(url, {
        path,
      })
      .then(() => {
        window.location.reload();
      })
      .catch(() =>
        createFlash({
          message: __('An error occurred while initializing path locks'),
        }),
      );
  });
}

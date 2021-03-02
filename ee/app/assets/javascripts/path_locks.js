import $ from 'jquery';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { __ } from '~/locale';

export default function initPathLocks(url, path) {
  $('a.path-lock').on('click', (e) => {
    e.preventDefault();

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

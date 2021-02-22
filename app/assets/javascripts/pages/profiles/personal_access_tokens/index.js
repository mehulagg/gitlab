import { initExpiresAtField } from '~/access_tokens';
import createFlash from '~/flash';
import { __ } from '~/locale';

initExpiresAtField();

if (window.gon.features.personalAccessTokensScopedToProjects) {
  import('~/access_tokens')
    .then(({ initProjectsField }) => {
      initProjectsField();
    })
    .catch(() => {
      createFlash(__('An error occurred while loading the access tokens form, please try again.'));
    });
}

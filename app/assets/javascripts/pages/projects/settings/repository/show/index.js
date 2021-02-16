import MirrorRepos from '~/mirrors/mirror_repos';
import initForm from '../form';
import initSearchSettings from '~/search_settings';

document.addEventListener('DOMContentLoaded', () => {
  initForm();

  const mirrorReposContainer = document.querySelector('.js-mirror-settings');
  if (mirrorReposContainer) new MirrorRepos(mirrorReposContainer).init();

  initSearchSettings();
});

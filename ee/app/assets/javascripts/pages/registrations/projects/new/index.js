import mountProgressBar from 'ee/registrations/projects/new';
import initProjectVisibilitySelector from '~/project_visibility';
import initProjectNew from '~/projects/project_new';

document.addEventListener('DOMContentLoaded', () => {
  mountProgressBar();
  initProjectVisibilitySelector();
  initProjectNew.bindEvents();
});

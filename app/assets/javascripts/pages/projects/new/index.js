import Vue from 'vue';
import initProjectVisibilitySelector from '../../../project_visibility';
import initProjectNew from '../../../projects/project_new';
import NewProjectCreationApp from './components/app.vue';

initProjectVisibilitySelector();
initProjectNew.bindEvents();

function initNewProjectCreation(el, props) {
  const { pushToCreateProjectCommand, workingWithProjectsHelpPath } = el.dataset;

  return new Vue({
    el,
    components: {
      NewProjectCreationApp,
    },
    provide: {
      workingWithProjectsHelpPath,
      pushToCreateProjectCommand,
    },
    render(h) {
      return h(NewProjectCreationApp, { props });
    },
  });
}

const el = document.querySelector('.js-new-project-creation');

const config = {
  hasErrors: 'hasErrors' in el.dataset,
  isCiCdAvailable: 'isCiCdAvailable' in el.dataset,
  newProjectGuidelines: el.dataset.newProjectGuidelines,
};

initNewProjectCreation(el, config);

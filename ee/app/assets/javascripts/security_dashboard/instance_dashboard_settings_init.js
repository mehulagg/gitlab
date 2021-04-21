import Vue from 'vue';
import ProjectManager from './components/first_class_project_manager/project_manager.vue';
import apolloProvider from './graphql/provider';

export default (el) => {
  if (!el) {
    return null;
  }

  return new Vue({
    el,
    apolloProvider,
    render(createElement) {
      return createElement(ProjectManager);
    },
  });
};

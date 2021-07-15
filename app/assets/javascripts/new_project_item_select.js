import Vue from 'vue';
import axios from './lib/utils/axios_utils';
import NewProjectItemSelect from '~/vue_shared/components/new_project_item_select.vue';

export default () => {
  const el = document.getElementById('js-new-project-item-select');
  let userFrequentProjects = JSON.parse(localStorage.getItem(`${gon.current_username}/frequent-projects`)); 
  const endpoint = `http://localhost:3000/api/v4/projects/`;

  function getUserFrequentProjects(projects) {
    projects.forEach(project => {
      axios.get(`${endpoint}${project.id}`).then((res) => {
        project.issues_enabled = res.data.issues_enabled;
        project.merge_requests_enabled = res.data.merge_requests_enabled;
      });
    })
  }

  getUserFrequentProjects(userFrequentProjects);

  return new Vue({
    el,
    render(createElement) {
      return createElement(NewProjectItemSelect, {
        props: {
          path: el.dataset.path,
          label: el.dataset.label,
          with_feature_enabled: el.dataset.with_feature_enabled,
          type: el.dataset.type,
          frequentProjects: userFrequentProjects,
        },
      });
    },
  });
};

import Vue from 'vue';
import CompareApp from './components/app.vue';
import CompareAppFF from './components/app_ff.vue';

export default function init() {
  const el = document.getElementById('js-compare-selector');

  if (gon.features.compareRepoDropdown) {
    const {
      refsProjectPath,
      paramsFrom,
      paramsTo,
      projectCompareIndexPath,
      projectMergeRequestPath,
      createMrPath,
      projectTo,
      projectsFrom,
    } = el.dataset;

    return new Vue({
      el,
      components: {
        CompareAppFF,
      },
      provide: {
        projectTo: JSON.parse(projectTo),
        projectsFrom: JSON.parse(projectsFrom),
      },
      render(createElement) {
        return createElement(CompareAppFF, {
          props: {
            refsProjectPath,
            paramsFrom,
            paramsTo,
            projectCompareIndexPath,
            projectMergeRequestPath,
            createMrPath,
          },
        });
      },
    });
  }

  const {
    refsProjectPath,
    paramsFrom,
    paramsTo,
    projectCompareIndexPath,
    projectMergeRequestPath,
    createMrPath,
  } = el.dataset;

  return new Vue({
    el,
    components: {
      CompareApp,
    },
    render(createElement) {
      return createElement(CompareApp, {
        props: {
          refsProjectPath,
          paramsFrom,
          paramsTo,
          projectCompareIndexPath,
          projectMergeRequestPath,
          createMrPath,
        },
      });
    },
  });
}

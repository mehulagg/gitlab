import Vue from 'vue';
import { expandSection, closeSection, isExpanded } from '~/settings_panels';
import SearchSettings from '~/search_settings/components/search_settings.vue';

const mountSearch = ({ el }) =>
  new Vue({
    el,
    render: (h) =>
      h(SearchSettings, {
        ref: 'searchSettings',
        props: {
          searchRoot: document.querySelector('#content-body'),
          sectionSelector: 'section.settings',
          isExpandedFn: isExpanded,
        },
        on: {
          collapse: closeSection,
          expand: expandSection,
        },
      }),
  });

export default mountSearch;

import Vue from 'vue';
import SortDropdown from './components/sort_dropdown.vue';

const mountDropdownApp = (el) => {
  const {
    projectBranchesFilteredPath,
    sortOptionNameAsc,
    sortOptionUpdatedAsc,
    sortOptionUpdatedDesc,
  } = el.dataset;

  return new Vue({
    el,
    name: 'SortBranchesDropdownApp',
    components: {
      SortDropdown,
    },
    provide: {
      projectBranchesFilteredPath,
      sortOptionNameAsc,
      sortOptionUpdatedAsc,
      sortOptionUpdatedDesc,
    },
    render: (createElement) => createElement(SortDropdown, {}),
  });
};

export default () => {
  const el = document.getElementById('js-branches-sort-dropdown');
  return !el ? {} : mountDropdownApp(el);
};

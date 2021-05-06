import Vue from 'vue';
import BindInOut from '~/behaviors/bind_in_out';
import initFilePickers from '~/file_pickers';
import Group from '~/group';
import NewGroupCreationApp from './components/app.vue';
import GroupPathValidator from './group_path_validator';

new GroupPathValidator(); // eslint-disable-line no-new

BindInOut.initAll();
initFilePickers();

new Group(); // eslint-disable-line no-new

function initNewGroupCreation(el, props = {}) {
  return new Vue({
    el,
    render(h) {
      return h(NewGroupCreationApp, { props });
    },
  });
}

const el = document.querySelector('.js-new-group-creation');

initNewGroupCreation(el, {});

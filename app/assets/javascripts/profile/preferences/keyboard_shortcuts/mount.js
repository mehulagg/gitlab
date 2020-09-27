import Vue from 'vue';
import Vuex from 'vuex';
import { keybindings } from '~/behaviors/shortcuts/keybindings';
import KeyboardShortcutsCustomization from './components/keyboard_shortcuts_customization.vue';
import createStore from './stores';

Vue.use(Vuex);

export default () => {
  const el = document.querySelector('#js-user-profile-keyboard-shortcut-customization');

  // The element will not exist if the feature flag for
  // keyboard shortcut customization has been disabled
  if (!el) return null;

  const initialState = {
    ...el.dataset,
    keybindings,
  };

  const store = createStore(initialState);

  return new Vue({
    el,
    store,
    render: h => h(KeyboardShortcutsCustomization),
  });
};

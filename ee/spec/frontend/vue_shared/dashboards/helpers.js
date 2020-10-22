import state from 'ee/vue_shared/dashboards/store/state';

export default function clearState(store) {
  store.replaceState(state());
}

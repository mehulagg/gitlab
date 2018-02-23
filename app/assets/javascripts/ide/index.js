import Vue from 'vue';
import ide from './components/ide.vue';
import store from './stores';
import router from './ide_router';
import Translate from '../vue_shared/translate';
import { dataStructure } from './stores/utils';

function initIde(el) {
  if (!el) return null;

  const f = {
    ...dataStructure(),
    changed: true,
    name: 'testing 123',
    path: 'testing 123',
    type: 'blob',
    raw: 'asd',
  };

  store.state.changedFiles.push(f);
  store.state.stagedFiles.push({
    ...f,
    raw: '12313123',
  });

  return new Vue({
    el,
    store,
    router,
    components: {
      ide,
    },
    render(createElement) {
      return createElement('ide', {
        props: {
          emptyStateSvgPath: el.dataset.emptyStateSvgPath,
          noChangesStateSvgPath: el.dataset.noChangesStateSvgPath,
          committedStateSvgPath: el.dataset.committedStateSvgPath,
        },
      });
    },
  });
}

const ideElement = document.getElementById('ide');

Vue.use(Translate);

initIde(ideElement);

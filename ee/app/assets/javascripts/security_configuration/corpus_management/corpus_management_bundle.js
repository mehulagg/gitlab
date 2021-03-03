import Vue from 'vue';
import CorpusManagement from './components/corpus_management.vue';

export default () => {
  const el = document.querySelector('.js-corpus-management');

  if (!el) {
    return undefined;
  }

  const {
    dataset: { projectFullPath },
  } = el;

  const props = {
    projectFullPath,
  };

  return new Vue({
    el,
    render(h) {
      return h(CorpusManagement, {
        props,
      });
    },
  });
};

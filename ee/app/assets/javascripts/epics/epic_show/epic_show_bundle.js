import Vue from 'vue';
import EpicShowApp from './components/epic_show_app.vue';

export default () => {
  const el = document.querySelector('#epic-show-app');
  const metaData = JSON.parse(el.dataset.meta);
  const initialData = JSON.parse(el.dataset.initial);

  const props = Object.assign({}, initialData, metaData);

  // Convert backend casing to match frontend style guide
  props.startDate = props.start_date;
  props.endDate = props.end_date;

  return new Vue({
    el,
    components: {
      'epic-show-app': EpicShowApp,
    },
    render: createElement => createElement('epic-show-app', {
      props,
    }),
  });
};

import Vue from 'vue';
import App from './components/app.vue';

export default () =>
  new Vue({
    el: document.getElementById('js-vue-awards-block'),
    data() {
      const { dataset } = this.$options.el;

      return {
        awards: JSON.parse(dataset.awards),
        canAward: dataset.canAward === 'true',
        awardUrl: dataset.awardUrl,
      };
    },
    render(createElement) {
      return createElement(App, {
        props: {
          defaultAwards: this.awards,
          canAward: this.canAward,
          awardUrl: this.awardUrl,
        },
      });
    },
  });

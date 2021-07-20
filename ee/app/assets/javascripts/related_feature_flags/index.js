import Vue from 'vue';
import RelatedFeatureFlags from './components/related_feature_flags.vue';

export default function initRelatedFeatureFlags() {
  const el = document.querySelector('#js-related-feature-flags-root');

  if (el) {
    /* eslint-disable-next-line no-new */
    new Vue({
      el,
      provide: { endpoint: el.dataset.endpoint },
      render(h) {
        return h(RelatedFeatureFlags);
      },
    });
  }
}

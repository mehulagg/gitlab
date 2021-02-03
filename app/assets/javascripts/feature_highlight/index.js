import Vue from 'vue';

const init = async () => {
  const el = document.querySelector('.js-feature-highlight');

  if (!el) {
    return null;
  }

  const { autoDevopsHelpPath, highlight: highlightId, dismissEndpoint } = el.dataset;
  const { default: FeatureHighlight } = await import(
    /* webpackChunkName: 'feature_highlight' */ './feature_highlight.vue'
  );

  return new Vue({
    el,
    render: (h) =>
      h(FeatureHighlight, {
        props: {
          autoDevopsHelpPath,
          highlightId,
          dismissEndpoint,
        },
      }),
  });
};

export default init;

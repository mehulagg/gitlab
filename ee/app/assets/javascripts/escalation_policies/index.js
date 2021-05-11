import Vue from 'vue';
import EscalationPoliciesWrapper from './components/escalation_policies_wrapper.vue';

export default () => {
  const el = document.querySelector('.js-escalation-policies');

  if (!el) return null;

  const { emptyEscalationPoliciesSvgPath, projectPath = '' } = el.dataset;

  return new Vue({
    el,
    provide: {
      projectPath,
      emptyEscalationPoliciesSvgPath,
    },
    render(createElement) {
      return createElement(EscalationPoliciesWrapper);
    },
  });
};

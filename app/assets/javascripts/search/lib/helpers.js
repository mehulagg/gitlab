import Vue from 'vue';

export const mountComponent = (vueInstance, component, id) => {
  const ComponentClass = Vue.extend(component);
  const instance = new ComponentClass();
  instance.$mount();

  const el = vueInstance.$el.querySelector(id);
  el.parentNode.replaceChild(instance.$el, el);
};

import Vue from 'vue';

export const mountComponent = (vueInstance, component, propsData, id) => {
  const ComponentClass = Vue.extend(component);
  const instance = new ComponentClass({ propsData, store: vueInstance.$store });
  instance.$mount();

  const el = vueInstance.$el.querySelector(id);

  if (el) {
    el.parentNode.replaceChild(instance.$el, el);
  }
};

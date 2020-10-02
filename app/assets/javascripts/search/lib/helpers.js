import Vue from 'vue';

export const mountComponent = (vueInstance, component, propsData, id) => {
  const ComponentClass = Vue.extend(component);
  const instance = new ComponentClass({ propsData, store: vueInstance.$store });
  instance.$mount(vueInstance.$el.querySelector(id));

  return instance;
};

import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import ExpiresAtField from './components/expires_at_field.vue';
import ProjectsField from './components/projects_field.vue';

const getInputAttrs = (el) => {
  const input = el.querySelector('input');

  return {
    id: input.id,
    name: input.name,
    placeholder: input.placeholder,
  };
};

export const initExpiresAtField = () => {
  const el = document.querySelector('.js-access-tokens-expires-at');

  if (!el) {
    return null;
  }

  const inputAttrs = getInputAttrs(el);

  return new Vue({
    el,
    render(h) {
      return h(ExpiresAtField, {
        props: {
          inputAttrs,
        },
      });
    },
  });
};

export const initProjectsField = () => {
  const el = document.querySelector('.js-access-tokens-projects');

  if (!el) {
    return null;
  }

  const inputAttrs = getInputAttrs(el);
  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(),
  });

  Vue.use(VueApollo);

  return new Vue({
    el,
    apolloProvider,
    render(h) {
      return h(ProjectsField, {
        props: {
          inputAttrs,
        },
      });
    },
  });
};

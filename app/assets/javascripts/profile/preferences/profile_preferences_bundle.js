import Vue from 'vue';
import ProfilePreferences from './components/profile_preferences.vue';

export default () => {
  const el = document.querySelector('#js-profile-preferences-app');
  const shouldParse = ['integrationViews', 'userFields'];

  const props = Object.keys(el.dataset).reduce((memo, key) => {
    let value = el.dataset[key];
    if (shouldParse.includes(key)) {
      value = JSON.parse(value);
    }

    return { ...memo, [key]: value };
  }, {});

  return new Vue({
    el,
    name: 'ProfilePreferencesApp',
    render: createElement =>
      createElement(ProfilePreferences, {
        props,
      }),
  });
};

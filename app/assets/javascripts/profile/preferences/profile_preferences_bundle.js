import Vue from 'vue';
import ProfilePreferences from './components/profile_preferences.vue';

export default () => {
  const el = document.querySelector('#js-profile-preferences-app');
  const { viewDiffsFileByFile = true, userTimeSettings } = gon?.features;
  const featureFlags = {
    viewDiffsFileByFile,
    userTimeSettings,
  };
  const shouldParse = [
    'dashboardChoices',
    'firstDayOfWeekChoicesWithDefault',
    'layoutChoices',
    'languageChoices',
    'projectViewChoices',
    'groupViewChoices',
    'integrationViews',
    'userFields',
  ];

  const provide = Object.keys(el.dataset).reduce(
    (memo, key) => {
      let value = el.dataset[key];
      if (shouldParse.includes(key)) {
        value = JSON.parse(value);
      }

      return { ...memo, [key]: value };
    },
    { featureFlags },
  );

  return new Vue({
    el,
    name: 'ProfilePreferencesApp',
    provide,
    render: createElement => createElement(ProfilePreferences),
  });
};

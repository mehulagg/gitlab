import Vue from 'vue';
import ProfilePreferences from './components/profile_preferences.vue';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

export default () => {
  const el = document.querySelector('#js-profile-preferences-app');
  const { viewDiffsFileByFile = true, userTimeSettings } = gon?.features;
  const featureFlags = {
    viewDiffsFileByFile,
  };
  const shouldParse = [
    'dashboardChoices',
    'firstDayOfWeekChoicesWithDefault',
    'layoutChoices',
    'languageChoices',
    'projectViewChoices',
    'groupViewChoices',
    'integrationViews',
    'themes',
    'schemes',
    'userFields',
  ];

  const props = Object.keys(el.dataset).reduce(
    (memo, key) => {
      let value = el.dataset[key];
      if (shouldParse.includes(key)) {
        value = JSON.parse(value);
      }
      if (typeof value === 'object' && !Array.isArray(value)) {
        value = convertObjectPropsToCamelCase(value);
      }

      return { ...memo, [key]: value };
    },
    { featureFlags },
  );

  return new Vue({
    el,
    name: 'CycleAnalyticsApp',
    render: createElement =>
      createElement(ProfilePreferences, {
        props,
      }),
  });
};

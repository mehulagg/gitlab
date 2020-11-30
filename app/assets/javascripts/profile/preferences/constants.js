import { s__ } from '~/locale';

export const INTEGRATION_VIEW_CONFIGS = {
  sourcegraph: {
    title: s__('ProfilePreferences|Sourcegraph'),
    label: s__('ProfilePreferences|Enable integrated code intelligence on code views'),
    formName: 'sourcegraph_enabled',
  },
  gitpod: {
    title: s__('ProfilePreferences|Gitpod'),
    label: s__('ProfilePreferences|Enable Gitpod integration'),
    formName: 'gitpod_enabled',
  },
};

export const i18n = {
  behavior: s__('ProfilePreferences|Behavior'),
  behaviorDescription: s__(
    'ProfilePreferences|This setting allows you to customize the behavior of the system layout and default views.',
  ),
  learnMore: s__('ProfilePreferences|Learn more'),
  layoutWidth: s__('ProfilePreferences|Layout width'),
  layoutWidthDescription: s__(
    'ProfilePreferences|Choose between fixed (max. 1280px) and fluid (100%) application layout.',
  ),
  homepageContent: s__('ProfilePreferences|Homepage content'),
  homepageContentDescription: s__(
    'ProfilePreferences|Choose what content you want to see on your homepage.',
  ),
  projectOverview: s__('ProfilePreferences|Project overview content'),
  projectOverviewDescription: s__(
    'ProfilePreferences|Choose what content you want to see on a project’s overview page.',
  ),
  renderWhitespaceLabel: s__('ProfilePreferences|Render whitespace characters in the Web IDE'),
  showWhitespaceLabel: s__('ProfilePreferences|Show whitespace changes in diffs'),
  showOneFileLabel: s__(
    'ProfilePreferences|Show one file at a time on merge request’s Changes tab',
  ),
  showOneFileDescription: s__(
    'ProfilePreferences|Instead of all the files changed, show only one file at a time. To switch between files, use the file browser.',
  ),
  tabWidth: s__('ProfilePreferences|Tab width'),
  tabWidthDescription: s__('ProfilePreferences|Must be a number between 1 and 12'),
  localization: s__('ProfilePreferences|Localization'),
  localizationDescription: s__(
    'ProfilePreferences|Customize language and region related settings.',
  ),
  language: s__('ProfilePreferences|Language'),
  experimentalDescription: s__(
    'ProfilePreferences|This feature is experimental and translations are not complete yet',
  ),
  firstDayOfTheWeek: s__('ProfilePreferences|First day of the week'),
  timePreferences: s__('ProfilePreferences|Time preferences'),
  timePreferencesDescription: s__(
    'ProfilePreferences|These settings will update how dates and times are displayed for you.',
  ),
  timeFormat: s__('ProfilePreferences|Time format'),
  timeFormatLabel: s__('ProfilePreferences|Display time in 24-hour format'),
  relativeTimeLabel: s__('ProfilePreferences|For example: 30 mins ago.'),
  integrations: s__('ProfilePreferences|Integrations'),
  integrationsDescription: s__(
    'ProfilePreferences|Customize integrations with third party services.',
  ),
};

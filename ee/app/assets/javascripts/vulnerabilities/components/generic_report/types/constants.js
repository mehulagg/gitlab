export const REPORT_TYPE_LIST = 'list';
export const REPORT_TYPE_URL = 'url';

export const REPORT_TYPES = [REPORT_TYPE_LIST, REPORT_TYPE_URL];

const REPORT_TYPE_TO_COMPONENT_MAP = {
  [REPORT_TYPE_LIST]: () => import('./list.vue'),
  [REPORT_TYPE_URL]: () => import('./url.vue'),
};

// eslint-disable-next-line @gitlab/require-i18n-strings
const suffixComponentName = (componentName) => `${componentName}Type`;

export const REPORT_TYPE_COMPONENTS = Object.fromEntries(
  Object.entries(REPORT_TYPE_TO_COMPONENT_MAP).map(([reportType, component]) => [
    // eslint-disable-next-line @gitlab/require-i18n-strings
    suffixComponentName(reportType),
    component,
  ]),
);

// eslint-disable-next-line @gitlab/require-i18n-strings
export const getComponentNameForType = (reportType) => suffixComponentName(reportType);

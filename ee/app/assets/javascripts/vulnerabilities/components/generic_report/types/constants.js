import { capitalizeFirstCharacter } from '~/lib/utils/text_utility';

export const REPORT_TYPES = {
  list: 'list',
  url: 'url',
};

const REPORT_TYPE_TO_COMPONENT_MAP = {
  [REPORT_TYPES.list]: () => import('./list.vue'),
  [REPORT_TYPES.url]: () => import('./url.vue'),
};

export const getComponentNameForType = (reportType) =>
  `ReportType${capitalizeFirstCharacter(reportType)}`;

export const REPORT_COMPONENTS = Object.fromEntries(
  Object.entries(REPORT_TYPE_TO_COMPONENT_MAP).map(([reportType, component]) => [
    getComponentNameForType(reportType),
    component,
  ]),
);

/*
 * Diff component
 */
const DIFF = 'diff';
const BEFORE = 'before';
const AFTER = 'after';

export const VIEW_TYPES = { DIFF, BEFORE, AFTER };

const NORMAL = 'normal';
const REMOVED = 'removed';
const ADDED = 'added';

export const LINE_TYPES = { NORMAL, REMOVED, ADDED };

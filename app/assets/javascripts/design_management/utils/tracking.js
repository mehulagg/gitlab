import Tracking from '~/tracking';

// Tracking Constants
const DESIGN_TRACKING_CONTEXT_SCHEMA = 'iglu:com.gitlab/design_management_context/jsonschema/1-0-0';
const DESIGN_TRACKING_PAGE_NAME = 'projects:issues:design';
const DESIGN_TRACKING_EVENTS = {
  VIEW_DESIGN: 'view_design',
  CREATE_DESIGN: 'create_design',
  UPDATE_DESIGN: 'update_design',
};

export function trackDesignDetailView(
  referer = '',
  owner = '',
  designVersion = 1,
  latestVersion = false,
) {
  const eventName = DESIGN_TRACKING_EVENTS.VIEW_DESIGN;
  Tracking.event(DESIGN_TRACKING_PAGE_NAME, eventName, {
    label: eventName,
    context: {
      schema: DESIGN_TRACKING_CONTEXT_SCHEMA,
      data: {
        'design-version-number': designVersion,
        'design-is-current-version': latestVersion,
        'internal-object-referrer': referer,
        'design-collection-owner': owner,
      },
    },
  });
}

export function trackDesignCreate() {
  const eventName = DESIGN_TRACKING_EVENTS.CREATE_DESIGN;
  Tracking.event(DESIGN_TRACKING_PAGE_NAME, eventName, {
    label: eventName,
    context: {
      schema: DESIGN_TRACKING_CONTEXT_SCHEMA,
      data: {},
    },
  });
}

export function trackDesignUpdate() {
  const eventName = DESIGN_TRACKING_EVENTS.UPDATE_DESIGN;
  Tracking.event(DESIGN_TRACKING_PAGE_NAME, eventName, {
    label: eventName,
    context: {
      schema: DESIGN_TRACKING_CONTEXT_SCHEMA,
      data: {},
    },
  });
}

import { s__ } from '~/locale';

export * from '~/vue_shared/security_reports/components/constants';

export const SEVERITY_TOOLTIP_TITLE_MAP = {
  unknown: s__(
    `SecurityReports|Sometimes a scanner can't determine a finding's severity. Those findings may still be a potential source of risk though. Please review these manually.`,
  ),
};

export const VULNERABILITY_MODAL_ID = 'modal-mrwidget-security-issue';
export const EMPTY_BODY_MESSAGE = '<Message body is not provided>';

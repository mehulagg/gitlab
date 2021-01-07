import { s__ } from '~/locale';

export * from '~/vue_shared/security_reports/components/constants';

export const SEVERITY_TOOLTIP_TITLE_MAP = {
  unknown: s__(
    `SecurityReports|The rating "unknown" indicates that the underlying scanner doesn’t contain or provide a severity rating.`,
  ),
};

export const VULNERABILITY_MODAL_ID = 'modal-mrwidget-security-issue';

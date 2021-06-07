import { s__ } from '~/locale';

export const ALERT_STATUSES = {
  ACKNOWLEDGED: s__('AlertManagement|Acknowledged'),
  RESOLVED: s__('AlertManagement|Resolved'),
};

export const ACTIONS = {
  EMAIL_ONCALL_SCHEDULE_USER: s__('EscalationPolicies|Email on-call user in schedule'),
};

export const defaultEscalationRule = {
  status: 'ACKNOWLEDGED',
  elapsedTimeSeconds: 0,
  action: 'EMAIL_ONCALL_SCHEDULE_USER',
  oncallScheduleIid: null,
};

export const addEscalationPolicyModalId = 'addEscalationPolicyModal';

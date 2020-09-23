import { s__ } from '~/locale';
import CE_TEMPLATES from '~/projects/default_project_templates';

export default {
  ...CE_TEMPLATES,
  hipaa_audit_protocol: {
    text: s__('ProjectTemplates|HIPAA Audit Protocol'),
    icon: '.template-option .icon-hipaa_audit_protocol',
  },
};

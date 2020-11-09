import { s__ } from '~/locale';

export const integrationLevels = {
  GROUP: 'group',
  INSTANCE: 'instance',
};

export const defaultIntegrationLevel = integrationLevels.INSTANCE;

export const overrideDropdownDescriptions = {
  [integrationLevels.GROUP]: s__(
    'Integrations|Default settings are inherited from the group level.',
  ),
  [integrationLevels.INSTANCE]: s__(
    'Integrations|Default settings are inherited from the instance level.',
  ),
};

export const uninstallOptions = [
  {
    value: true,
    label: s__('Integrations|Apply to all inheriting projects'),
    help: s__(
      'Integrations|All projects inheriting these settings will be cleared and deactivated',
    ),
  },
  {
    value: false,
    label: s__('Integrations|Do not apply to all inheriting projects'),
    help: s__('Integrations|Projects will be switched to custom settings and remain active'),
  },
];

import { s__ } from '~/locale';
import {
  REPORT_TYPE_DEPENDENCY_SCANNING,
  REPORT_TYPE_SECRET_DETECTION,
} from '~/vue_shared/security_reports/constants';
import configureDependencyScanningMutation from '../graphql/configure_dependency_scanning.mutation.graphql';
import configureSecretDetectionMutation from '../graphql/configure_secret_detection.mutation.graphql';

export const SMALL = 'SMALL';
export const MEDIUM = 'MEDIUM';
export const LARGE = 'LARGE';

// The backend will supply sizes matching the keys of this map; the values
// correspond to values acceptable to the underlying components' size props.
export const SCHEMA_TO_PROP_SIZE_MAP = {
  [SMALL]: 'xs',
  [MEDIUM]: 'md',
  [LARGE]: 'xl',
};

export const CUSTOM_VALUE_MESSAGE = s__(
  "SecurityConfiguration|Using custom settings. You won't receive automatic updates on this variable. %{anchorStart}Restore to default%{anchorEnd}",
);

export const featureToMutationMap = {
  [REPORT_TYPE_DEPENDENCY_SCANNING]: {
    type: 'configureDependencyScanning',
    mutation: configureDependencyScanningMutation,
  },
  [REPORT_TYPE_SECRET_DETECTION]: {
    type: 'configureSecretDetection',
    mutation: configureSecretDetectionMutation,
  },
};

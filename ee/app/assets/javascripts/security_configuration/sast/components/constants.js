import { s__ } from '~/locale';

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

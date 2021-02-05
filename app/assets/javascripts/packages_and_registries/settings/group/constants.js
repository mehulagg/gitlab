import { s__, __ } from '~/locale';
import { helpPagePath } from '~/helpers/help_page_helper';

export const PACKAGE_SETTINGS_HEADER = s__('PackageRegistry|Package Registry');
export const PACKAGE_SETTINGS_DESCRIPTION = s__(
  'PackageRegistry|GitLab Packages allows organizations to utilize GitLab as a private repository for a variety of common package formats. %{linkStart}More Information%{linkEnd}',
);

export const MAVEN_TITLE = s__('PackageRegistry|Maven');
export const MAVEN_SETTINGS_SUBTITLE = s__('PackageRegistry|Settings for Maven packages');
export const MAVEN_DUPLICATES_ALLOWED_DISABLED = s__(
  'PackageRegistry|%{boldStart}Do not allow duplicates%{boldEnd} - Packages with the same name and version are rejected.',
);
export const MAVEN_DUPLICATES_ALLOWED_ENABLED = s__(
  'PackageRegistry|%{boldStart}Allow duplicates%{boldEnd} - Packages with the same name and version are accepted.',
);
export const MAVEN_SETTING_EXCEPTION_TITLE = __('Exceptions');
export const MAVEN_SETTINGS_EXCEPTION_LEGEND = s__(
  'PackageRegistry|Packages can be published if their name or version matches this regex',
);

export const SUCCESS_UPDATING_SETTINGS = s__('PackageRegistry|Settings saved successfully');
export const ERROR_UPDATING_SETTINGS = s__(
  'PackageRegistry|An error occurred while saving the settings',
);

// Parameters

export const PACKAGES_DOCS_PATH = helpPagePath('user/packages');
export const MAVEN_DUPLICATES_ALLOWED = 'mavenDuplicatesAllowed';
export const MAVEN_DUPLICATE_EXCEPTION_REGEX = 'mavenDuplicateExceptionRegex';

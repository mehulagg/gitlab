import { SEVERITY_LEVELS } from 'ee/security_dashboard/store/constants';
import { s__, sprintf } from '~/locale';
import sha1 from 'sha1';
import _ from 'lodash-es';
import { enrichVulnerabilityWithFeedback } from '../utils';

/*
  Container scanning mapping utils
  This file contains all functions for mapping container scanning vulnerabilities
  to match the representation that we are building in the backend:

  https://gitlab.com/gitlab-org/gitlab/blob/bbcd07475f0334/ee/lib/gitlab/ci/parsers/security/container_scanning.rb

  All these function can hopefully be removed as soon as we retrieve the data from the backend.
 */

export const formatContainerScanningDescription = ({
  description,
  namespace,
  vulnerability,
  featurename,
  featureversion,
}) => {
  if (!_.isEmpty(description)) {
    return description;
  }

  let generated;

  if (featurename && featureversion) {
    generated = `${featurename}:${featureversion}`;
  } else if (featurename) {
    generated = featurename;
  } else {
    generated = namespace;
  }

  return sprintf(s__('ciReport|%{namespace} is affected by %{vulnerability}.'), {
    namespace: generated,
    vulnerability,
  });
};

export const formatContainerScanningMessage = ({ vulnerability, featurename }) => {
  if (featurename) {
    return sprintf(s__('ciReport|%{vulnerability} in %{featurename}'), {
      vulnerability,
      featurename,
    });
  }
  return vulnerability;
};

export const formatContainerScanningSolution = ({ fixedby, featurename, featureversion }) => {
  if (!_.isEmpty(fixedby)) {
    if (!_.isEmpty(featurename)) {
      if (!_.isEmpty(featureversion)) {
        return sprintf(s__('ciReport|Upgrade %{name} from %{version} to %{fixed}.'), {
          name: featurename,
          version: featureversion,
          fixed: fixedby,
        });
      }

      return sprintf(s__('ciReport|Upgrade %{name} to %{fixed}.'), {
        name: featurename,
        fixed: fixedby,
      });
    }

    return sprintf(s__('ciReport|Upgrade to %{fixed}.'), {
      fixed: fixedby,
    });
  }

  return null;
};

export const parseContainerScanningSeverity = severity => {
  /* eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings */
  if (severity === 'Defcon1') {
    return SEVERITY_LEVELS.critical;
    /* eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings */
  } else if (severity === 'Negligible') {
    return SEVERITY_LEVELS.low;
  }
  return severity;
};

/**
 * Parses Container Scanning results into a common format to allow to use the same Vue component.
 * Container Scanning report is currently the straight output from the underlying tool
 * (clair scanner) hence the formatting happening here.
 *
 * @param {Array} issues
 * @param {Array} feedback
 * @param {String} image name
 * @returns {Array}
 */
export const parseSastContainer = (issues = [], feedback = [], image) =>
  issues.map(issue => {
    const message = formatContainerScanningMessage(issue);

    /*
     The following fields are copying the backend data structure, as can be found in:
     https://gitlab.com/gitlab-org/gitlab/blob/f8f5724bb47712df0a618ae0a447b69a6ef47c0c/ee/lib/gitlab/ci/parsers/security/container_scanning.rb#L42-72
     */
    const parsed = {
      category: 'container_scanning',
      message,
      description: formatContainerScanningDescription(issue),
      cve: issue.vulnerability,
      severity: parseContainerScanningSeverity(issue.severity),
      confidence: SEVERITY_LEVELS.medium,
      location: {
        image,
        operating_system: issue.namespace,
      },
      /* eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings */
      scanner: { id: 'clair', name: 'Clair' },
      identifiers: [
        {
          type: 'CVE',
          name: issue.vulnerability,
          value: issue.vulnerability,
          url: `https://cve.mitre.org/cgi-bin/cvename.cgi?name=${issue.vulnerability}`,
        },
      ],
    };

    const solution = formatContainerScanningSolution(issue);

    if (solution) {
      parsed.solution = solution;
    }

    if (issue.featurename) {
      const dependency = {
        package: {
          name: issue.featurename,
        },
      };
      if (issue.featureversion) {
        dependency.version = issue.featureversion;
      }
      parsed.location.dependency = dependency;
    }

    if (issue.link) {
      parsed.links = [{ url: issue.link }];
    }

    /*
     The following properties are set only created in the frontend.
     This is done for legacy reasons and they should be made obsolete,
     before switching to the Backend implementation
     */
    const frontendOnly = {
      project_fingerprint: sha1(
        `${issue.namespace}:${issue.vulnerability}:${issue.featurename}:${issue.featureversion}`,
      ),
      title: message,
      vulnerability: issue.vulnerability,
    };

    return {
      ...parsed,
      ...frontendOnly,
      ...enrichVulnerabilityWithFeedback(frontendOnly, feedback),
    };
  });

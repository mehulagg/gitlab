<script>
import { GlIcon } from '@gitlab/ui';
import { __, s__ } from '~/locale'; // eslint-disable-line no-unused-vars
import { joinPaths } from '~/lib/utils/url_utility';
import tooltip from '~/vue_shared/directives/tooltip';

export default {
  components: {
    GlIcon,
  },

  directives: {
    tooltip,
  },

  props: {
    iid: {
      required: true,
      type: String,
    },
    fullPath: {
      required: true,
      type: String,
    },
    issueTitle: {
      required: true,
      type: String,
    },
  },

  data() {
    return {
      showHelp: false,
    };
  },

  computed: {
    helpHref() {
      return joinPaths(gon.relative_url_root || '', '/help/user/project/cve_id_request.md');
    },
    showHelpState() {
      return Boolean(this.showHelp);
    },
  },


  methods: {
    toggleHelpState(show) {
      this.showHelp = show;
    },

    createCveIdRequestUrl() {
      const currUrl = new URL(window.location.href);
      const newUrl = new URL(currUrl.origin);
      newUrl.pathname = '/gitlab-org/cves/-/issues/new';

      const params = {
        'issue[confidential]': 'true',
        // eslint-disable-next-line @gitlab/require-i18n-strings
        'issue[title]': `CVE ID Request - ${this.fullPath}`,
        'issue[description]': `
**NOTE:** Only maintainers of GitLab-hosted projects may request a CVE for
a vulnerability within their project.

Project issue: ${this.fullPath}#${this.iid}

After a CVE request is validated, a CVE identifier will be assigned. On what
schedule should the details of the CVE be published?

* [ ] Publish immediately
* [ ] Wait to publish

<!--
Please fill out the yaml codeblock below
-->

\`\`\`yaml
vulnerability:
  description: "TODO" # "[VULNTYPE] in [COMPONENT] in [VENDOR][PRODUCT] [VERSION] allows [ATTACKER] to [IMPACT] via [VECTOR]"
  cwe: "TODO" # "CWE-22" # Path Traversal
  product:
    gitlab_path: "${this.fullPath}"
    vendor: "TODO" # "Deluxe Sandwich Maker Company"
    name: "TODO" # "Deluxe Sandwich Maker 2"
    affected_versions:
      - "TODO" # "1.2.3"
      - "TODO" # ">1.3.0, <=1.3.9"
    fixed_versions:
      - "TODO" # "1.2.4"
      - "TODO" # "1.3.10"
  impact: "TODO" # "CVSS v3 string" # https://nvd.nist.gov/vuln-metrics/cvss/v3-calculator
  solution: "TODO" # "Upgrade to version 1.2.4 or 1.3.10"
  credit: "TODO"
  references:
    - "TODO" # "https://some.domain.tld/a/reference"
\`\`\`

CVSS scores can be computed by means of the [NVD CVSS Calculator](https://nvd.nist.gov/vuln-metrics/cvss/v3-calculator).

/relate ${this.fullPath}#${this.iid}
/label ~"devops::secure" ~"group::vulnerability research" ~"vulnerability research::cve" ~"advisory::queued"
        `,
      };
      Object.keys(params).forEach(k => newUrl.searchParams.append(k, params[k]));

      return newUrl.toString();
    },
  },
};
</script>

<template>
  <div class="block cve-id-request">
    <div
      v-tooltip
      title="CVE"
      class="sidebar-collapsed-icon"
      data-container="body"
      data-placement="left"
      data-boundary="viewport"
    >
      <gl-icon name="bug" class="sidebar-item-icon is-active" />
    </div>

    <div class="hide-collapsed">
      {{ s__('CVE|Request CVE ID') }}
      <div v-if="!showHelpState" class="help-button float-right" @click="toggleHelpState(true)">
        <gl-icon name="question-o" />
      </div>
      <div
        v-if="showHelpState"
        class="close-help-button float-right"
        @click="toggleHelpState(false)"
      >
        <gl-icon name="close" />
      </div>

      <div class="cve-id-request-content">
        <a
          :href="createCveIdRequestUrl()"
          target="_blank"
          class="btn btn-default btn-block js-cve-id-request-button"
          data-qa-selector="cve_id_request_button"
          >{{ s__('CVE|Create CVE ID Request') }}</a
        >
      </div>

      <div class="hide-collapsed">
        <transition name="help-state-toggle">
          <div v-if="showHelpState" class="cve-id-request-help-state">
            <h4>{{ s__('CVE|Why Request a CVE ID?') }}</h4>
            <p>
              {{
                s__(
                  'CVE|Common Vulnerability Enumeration (CVE) identifiers are used to track distinct vulnerabilities in specific versions of code.',
                )
              }}
            </p>

            <p>
              {{
                s__(
                  'CVE|As a maintainer, requesting a CVE for a vulnerability in your project will help your users stay secure and informed.',
                )
              }}
            </p>

            <div>
              <a
                :href="helpHref"
                target="_blank"
                class="btn btn-default js-cve-id-request-learn-more-link"
                data-qa-selector="cve_id_request_learn_more_link"
                >{{ __('Learn more') }}</a
              >
            </div>
          </div>
        </transition>
      </div>
    </div>
  </div>
</template>

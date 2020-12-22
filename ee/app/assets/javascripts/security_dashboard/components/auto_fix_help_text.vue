<script>
import { GlBadge, GlPopover, GlIcon, GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';

const ICONCOLOR = {
  opened: 'gl-text-green-500',
  closed: 'gl-text-red-500',
  merged: 'gl-text-blue-500',
};

const ICON = {
  opened: 'issue-open-m',
  closed: 'issue-close',
  merged: 'merge',
};

export default {
  components: {
    GlBadge,
    GlIcon,
    GlPopover,
    GlSprintf,
  },
  props: {
    mergeRequest: {
      type: Object,
      required: true,
    },
  },
  methods: {
    getIconColor(state) {
      return ICONCOLOR[state] || 'gl-text-gray-500';
    },
    getIcon(state) {
      return ICON[state] || 'issue-open-m';
    },
    autoFixMessage() {
      return s__('AutoRemediation|: %{autoFix}');
    },
  },
};
</script>

<template>
  <div ref="popover" data-testid="vulnerability-solutions-bulb">
    <gl-badge ref="badge" variant="neutral" icon="merge-request" />
    <gl-popover
      data-testid="vulnerability-solutions-popover"
      :target="() => $refs.popover"
      placement="top"
      triggers="hover focus"
    >
      <template #title>
        <span>{{ s__('AutoRemediation| 1 Merge Request') }}</span>
      </template>
      <ul class="gl-list-style-none gl-pl-0 gl-mb-0">
        <li class="gl-align-items-center gl-display-flex gl-mb-2">
          <gl-icon
            data-testid="vulnerability-solutions-popover-icon"
            :name="getIcon(mergeRequest.state)"
            :size="16"
            :class="getIconColor(mergeRequest.state)"
          />
          <a
            data-testid="vulnerability-solutions-popover-link"
            :href="mergeRequest.webUrl"
            class="gl-ml-3"
          >
            <span data-testid="vulnerability-solutions-popover-link-id"
              >!{{ mergeRequest.iid
              }}<span
                v-if="mergeRequest.securityAutoFix"
                data-testid="vulnerability-solutions-popover-link-autofix"
                ><gl-sprintf :message="autoFixMessage()">
                  <template #autoFix>{{ s__('AutoRemediation|Auto-fix') }}</template>
                </gl-sprintf></span
              >
            </span>
          </a>
        </li>
      </ul>
    </gl-popover>
  </div>
</template>

<script>
import { GlPopover, GlSprintf, GlLink } from '@gitlab/ui';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

export default {
  name: 'CascadingSettingLockPopover',
  components: {
    GlPopover,
    GlSprintf,
    GlLink,
  },
  data() {
    return {
      targets: [],
    };
  },
  mounted() {
    this.targets = [
      ...document.querySelectorAll('.js-cascading-setting-lock-popover-target'),
    ].flatMap((el) => {
      const { lockedByNamespace = {} } = el.dataset;
      const parsedLockedByNamespace = convertObjectPropsToCamelCase(JSON.parse(lockedByNamespace));

      if (!parsedLockedByNamespace.fullName || !parsedLockedByNamespace.path) {
        return [];
      }

      return {
        el,
        namespace: parsedLockedByNamespace,
      };
    });
  },
};
</script>

<template>
  <div>
    <gl-popover
      v-for="(target, index) in targets"
      :key="index"
      :target="target.el"
      :triggers="['hover', 'focus']"
      placement="top"
    >
      <template #title>
        <span aria-hidden="true">{{ __('Setting enforced') }}</span>
      </template>
      <p>
        <gl-sprintf :message="__('This setting has been enforced by an owner of %{link}.')">
          <template #link>
            <gl-link :href="target.namespace.path" class="gl-font-sm" target="_blank">{{
              target.namespace.fullName
            }}</gl-link>
          </template>
        </gl-sprintf>
      </p>
    </gl-popover>
  </div>
</template>

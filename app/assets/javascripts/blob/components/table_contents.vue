<script>
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';

function getHeaderNumber(el) {
  return parseInt(el.tagName.match(/\d+/)[0], 10);
}

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
  },
  data() {
    return {
      items: [],
    };
  },
  mounted() {
    this.blobViewer = document.querySelector('.blob-viewer[data-type="rich"]');

    const observer = new MutationObserver((mutations) => {
      mutations.forEach(() => {
        if (this.blobViewer.getAttribute('data-loaded') === 'true') {
          this.generateHeaders();
        }
      });
    });

    observer.observe(this.blobViewer, {
      attributes: true,
    });
  },
  methods: {
    generateHeaders() {
      const headers = [...this.blobViewer.querySelectorAll('h1,h2,h3,h4,h5,h6')];

      if (headers.length) {
        const firstHeader = getHeaderNumber(headers[0]);

        headers.forEach((el) => {
          this.items.push({
            text: el.textContent.trim(),
            anchor: el.querySelector('a').getAttribute('id'),
            spacing: Math.max((getHeaderNumber(el) - firstHeader) * 12, 0),
          });
        });
      }
    },
  },
};
</script>

<template>
  <gl-dropdown icon="list-bulleted" class="gl-mr-2">
    <gl-dropdown-item v-for="(item, index) in items" :key="index" :href="`#${item.anchor}`" lazy>
      <span
        :class="{ 'gl-font-weight-bold': item.spacing === 0 }"
        :style="{ 'padding-left': `${item.spacing}px` }"
      >
        {{ item.text }}
      </span>
    </gl-dropdown-item>
  </gl-dropdown>
</template>

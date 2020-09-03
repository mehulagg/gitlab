<script>
import { GlTooltipDirective, GlFriendlyWrap, GlIcon } from '@gitlab/ui';

export default {
  name: 'TestSuiteTableRow',
  components: {
    GlIcon,
    GlFriendlyWrap,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    index: {
      type: Number,
      required: true,
    },
    source: {
      type: Object,
      required: true,
    },
  },
  wrapSymbols: ['::', '#', '.', '_', '-', '/', '\\'],
};
</script>
<template>
  <div class="gl-responsive-table-row rounded align-items-md-start mt-xs-3 js-case-row">
    <div class="table-section section-20 section-wrap">
      <div role="rowheader" class="table-mobile-header">{{ __('Suite') }}</div>
      <div class="table-mobile-content pr-md-1 gl-overflow-wrap-break">
        <gl-friendly-wrap :symbols="$options.wrapSymbols" :text="source.classname" />
      </div>
    </div>

    <div class="table-section section-20 section-wrap">
      <div role="rowheader" class="table-mobile-header">{{ __('Name') }}</div>
      <div class="table-mobile-content pr-md-1 gl-overflow-wrap-break">
        <gl-friendly-wrap
          data-testid="caseName"
          :symbols="$options.wrapSymbols"
          :text="source.name"
        />
      </div>
    </div>

    <div class="table-section section-10 section-wrap">
      <div role="rowheader" class="table-mobile-header">{{ __('Status') }}</div>
      <div class="table-mobile-content text-center">
        <div
          class="add-border ci-status-icon d-flex align-items-center justify-content-end justify-content-md-center"
          :class="`ci-status-icon-${source.status}`"
        >
          <gl-icon :size="24" :name="source.icon" />
        </div>
      </div>
    </div>

    <div class="table-section flex-grow-1">
      <div role="rowheader" class="table-mobile-header">{{ __('Trace'), }}</div>
      <div class="table-mobile-content">
        <pre
          v-if="source.system_output"
          class="build-trace build-trace-rounded text-left"
        ><code class="bash p-0">{{source.system_output}}</code></pre>
      </div>
    </div>

    <div class="table-section section-10 section-wrap">
      <div role="rowheader" class="table-mobile-header">
        {{ __('Duration') }}
      </div>
      <div class="table-mobile-content text-right pr-sm-1">
        {{ source.formattedTime }}
      </div>
    </div>
  </div>
</template>

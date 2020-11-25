<script>
  import {GlButton, GlCard} from '@gitlab/ui';
  import {s__} from '~/locale';

  export const i18n = {
    title: s__('OnCallSchedules|On-call schedule'),
    cardHeader: s__('OnCallSchedules|Dev on-call schedule'),
  };

  export default {
    i18n,
    inject: ['emptyOncallSchedulesSvgPath'],
    components: {
      GlButton,
      GlCard,
    },
    props: {
      schedule: {
        type: Object,
        required: true,
      }
    },
    directives: {},
    methods: {},
  };
</script>

<template>
  <div>

    <h4>{{$options.i18n.title}}</h4>

    <gl-card>
      <template #header>
        <span class="gl-font-weight-bold gl-font-lg">{{$options.i18n.cardHeader}}</span>
      </template>
      Hello World
    </gl-card>
  </div>
</template>

<script>
    import {GlButton} from '@gitlab/ui';
    export default { props: {
        item: {
            type: Object,
            required: true
        }
    },
    components: {
        GlButton
    }, 
    };
</script>

<template>
    <gl-button variant="success" category="secondary">Configure via Merge Request</gl-button>
</template>

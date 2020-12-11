<script>
    import {GLButton} from '@gitlab/ui';
    export default { props: {
        components: {
            GLButton
        },
        item: {
            type: Object,
            required: true
        }
    } };
</script>

<template>
    <gl-button variant="success" category="secondary">Configure via Merge Request</gl-button>
</template>

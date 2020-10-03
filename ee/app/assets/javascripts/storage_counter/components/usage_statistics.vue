<script>
import { s__ } from '~/locale';
import { numberToHumanSize } from '~/lib/utils/number_utils';

export default {};
</script>
<template>
  <div class="gl-display-flex">
    <div class="gl-p-5 gl-my-5 gl-bg-gray-10 gl-flex-fill-1 gl-mx-4">
      <div>
        <p>
          <span class="gl-font-size-h-display">25.5</span>
          <span class="gl-font-size-lg">GB</span>
        </p>
        <p class="gl-border-b-1 gl-border-b-solid gl-border-b-gray-10">
          Total namespace storage used
        </p>
        <p>
          Learn more about usage quotas
        </p>
      </div>
    </div>
    <div class="gl-p-5 gl-my-5 gl-bg-gray-10 gl-flex-fill-1 gl-mx-4">
      <div>
        <p><span class="gl-font-size-h-display">0</span> <span class="gl-font-size-lg">GB</span></p>
        <p class="gl-border-b-1 gl-border-b-solid gl-border-b-gray-100">
          Total excess storage used
        </p>
        <p>
          Learn more excess storage usage
        </p>
      </div>
    </div>
    <div class="gl-p-5 gl-my-5 gl-bg-gray-10 gl-flex-fill-1 gl-ml-4 gl-mr-2">
      <div>
        <p>
          <span class="gl-font-size-h-display">0</span>
          <span class="gl-font-size-lg">GB</span>
        </p>
        <p class="gl-border-b-1 gl-border-b-solid gl-border-b-gray-100">
          Purchased storage available
        </p>
        <p>
          Purchase more storage
        </p>
      </div>
    </div>
  </div>
</template>

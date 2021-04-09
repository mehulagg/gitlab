<template>
  <div
    class="row gl-flex-grow-1 gl-flex-direction-column flex-nowrap gl-lg-flex-direction-row flex-xl-row flex-lg-wrap flex-xl-wrap"
  >
    <div
      class="checkout-pane gl-px-3 gl-align-items-center gl-bg-gray-10 col-lg-7 gl-display-flex gl-flex-direction-column gl-flex-grow-1"
    >
      <slot name="checkout"></slot>
    </div>
    <div
      class="gl-pb-3 gl-px-3 px-lg-7 col-lg-5 gl-display-flex gl-flex-direction-row gl-justify-content-center"
    >
      <slot name="order-summary"></slot>
    </div>
  </div>
</template>

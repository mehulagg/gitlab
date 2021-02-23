export const GlFormGroup = {
  name: 'gl-form-group-stub',
  props: ['state'],
  template: `
  <div>
    <slot name="label"></slot>
    <slot></slot>
    <slot name="description"></slot>
  </div>`,
};

export const GlFormInput = {
  name: 'gl-form-input-stub',
  props: ['state', 'disabled', 'value'],
  template: `
  <div>
    <slot></slot>
  </div>`,
};

export default class DirtyFormChecker {
  constructor(formSelector, onChange) {
    this.form = document.querySelector(formSelector);
    this.onChange = onChange;
    this.isDirty = false;

    this.editableInputs = Array.from(this.form.querySelectorAll('input[name]')).filter(
      (el) =>
        (el.type !== 'submit' && el.type !== 'hidden') ||
        el.classList.contains('js-project-feature-toggle-input'),
    );

    this.startingStates = {};
    this.editableInputs.forEach((input) => {
      this.startingStates[input.name] = input.value;
    });
  }

  init() {
    this.form.addEventListener('input', (event) => {
      if (event.target.matches('input[name]')) {
        this.recalculate();
      }
    });
  }

  recalculate() {
    const wasDirty = this.isDirty;
    this.isDirty = this.editableInputs.some((input) => {
      const currentValue = input.value;
      const startValue = this.startingStates[input.name];

      return currentValue !== startValue;
    });

    if (this.isDirty !== wasDirty) {
      this.onChange();
    }
  }
}

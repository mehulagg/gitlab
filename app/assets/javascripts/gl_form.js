import $ from 'jquery';
import autosize from 'autosize';
import GfmAutoComplete, { defaultAutocompleteConfig } from 'ee_else_ce/gfm_auto_complete';
import dropzoneInput from './dropzone_input';
import { addMarkdownListeners, removeMarkdownListeners } from './lib/utils/text_markdown';
import { disableButtonIfEmptyField } from '~/lib/utils/common_utils';

export default class GLForm {
  /**
   * Create a GLForm
   *
   * **Why is forceNew needed?**
   * Previously GLForm would calculate based on a class if something was needed or not. In Vue,
   * it's possible for classes to be rerendered and lost. We need a way to tell GLForm to treat
   * the given element as a new form, even if the class `gfm-form` already exists on it.
   *
   * @param {jQuery} form Root element of the GLForm
   * @param {Object} enableGFM Object that represents which autocomplete features to enable
   * @param {Boolean} forceNew A flag used to force this class to treat the element as a **new** form, and call Setup.
   */
  constructor(form, enableGFM = {}, forceNew = false) {
    this.form = form;
    this.textarea = this.form.find('textarea.js-gfm-input');
    this.enableGFM = { ...defaultAutocompleteConfig, ...enableGFM };

    // Disable autocomplete for keywords which do not have dataSources available
    const dataSources = (gl.GfmAutoComplete && gl.GfmAutoComplete.dataSources) || {};
    Object.keys(this.enableGFM).forEach(item => {
      if (item !== 'emojis' && !dataSources[item]) {
        this.enableGFM[item] = false;
      }
    });

    // Before we start, we should clean up any previous data for this form
    this.destroy();
    // Set up the form
    this.setupForm(forceNew);
    this.form.data('glForm', this);
  }

  destroy() {
    // Clean form listeners
    this.clearEventListeners();
    if (this.autoComplete) {
      this.autoComplete.destroy();
    }
    if (this.formDropzone) {
      this.formDropzone.destroy();
    }

    this.form.data('glForm', null);
  }

  setupForm(forceNew = false) {
    const isNewForm = this.form.is(':not(.gfm-form)') || forceNew;
    this.form.removeClass('js-new-note-form');
    if (isNewForm) {
      this.form.find('.div-dropzone').remove();
      this.form.addClass('gfm-form');
      // remove notify commit author checkbox for non-commit notes
      disableButtonIfEmptyField(
        this.form.find('.js-note-text'),
        this.form.find('.js-comment-button, .js-note-new-discussion'),
      );
      this.autoComplete = new GfmAutoComplete(gl.GfmAutoComplete && gl.GfmAutoComplete.dataSources);
      this.autoComplete.setup(this.form.find('.js-gfm-input'), this.enableGFM);
      this.formDropzone = dropzoneInput(this.form, { parallelUploads: 1 });
      autosize(this.textarea);
    }
    // form and textarea event listeners
    this.addEventListeners();
    addMarkdownListeners(this.form);
    this.form.show();
    if (this.isAutosizeable) this.setupAutosize();
  }

  setupAutosize() {
    this.textarea.off('autosize:resized').on('autosize:resized', this.setHeightData.bind(this));

    this.textarea.off('mouseup.autosize').on('mouseup.autosize', this.destroyAutosize.bind(this));

    setTimeout(() => {
      autosize(this.textarea);
      this.textarea.css('resize', 'vertical');
    }, 0);
  }

  setHeightData() {
    this.textarea.data('height', this.textarea.outerHeight());
  }

  destroyAutosize() {
    const outerHeight = this.textarea.outerHeight();

    if (this.textarea.data('height') === outerHeight) return;

    autosize.destroy(this.textarea);

    this.textarea.data('height', outerHeight);
    this.textarea.outerHeight(outerHeight);
    this.textarea.css('max-height', window.outerHeight);
  }

  clearEventListeners() {
    this.textarea.off('focus');
    this.textarea.off('blur');
    removeMarkdownListeners(this.form);
  }

  addEventListeners() {
    this.textarea.on('focus', function focusTextArea() {
      $(this)
        .closest('.md-area')
        .addClass('is-focused');
    });
    this.textarea.on('blur', function blurTextArea() {
      $(this)
        .closest('.md-area')
        .removeClass('is-focused');
    });
  }

  get supportsQuickActions() {
    return Boolean(this.textarea.data('supports-quick-actions'));
  }
}

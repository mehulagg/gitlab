import createSanitizer from 'dompurify';

const sanitizer = createSanitizer(window);

sanitizer.addHook('afterSanitizeAttributes', (node) => {
  node.setAttribute('target', '_blank');
  node.setAttribute('rel', 'noopener');
});

// This rest of this file was copied from https://gitlab.com/gitlab-org/gitlab-ui/-/blob/main/src/directives/safe_html/safe_html.js

const DEFAULT_CONFIG = { RETURN_DOM_FRAGMENT: true };

const transform = (el, binding) => {
  if (binding.oldValue !== binding.value) {
    const config = { ...DEFAULT_CONFIG, ...(binding.arg ?? {}) };

    el.textContent = '';
    el.appendChild(sanitizer.sanitize(binding.value, config));
  }
};

const SafeHtmlDirective = {
  bind: transform,
  update: transform,
};

export default SafeHtmlDirective;

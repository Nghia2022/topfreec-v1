import jQuery from 'jquery';

class FormDependent {
  constructor(container) {
    this.setupEvents(container);
  }

  setupEvents(container) {
    jQuery(container).find('[data-dependent]').each((i, element) => {
      const $elm = $(element);
      const id = $elm.data('dependent');
      jQuery(`#${id}`)
        .change(e => {
          const disabled = !$(e.target).val()
          if (disabled) {
            $elm.css({ opacity: 0.5, pointerEvents: 'none' });
            $elm.val('');
          } else {
            $elm.css({ opacity: 1.0, pointerEvents: 'auto' });
          }
          jQuery(`#${element.id}`).change();
        })
        .change();
    });
  }
}

export { FormDependent };

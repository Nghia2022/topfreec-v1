import jQuery from 'jquery';

class UploadFileName {
  constructor() {
    this.setupEvents();
  }

  setupEvents() {
    jQuery(document).on('change', '.jsUploadFile', function () {
      const $element = jQuery(this);
      const file = $element.prop('files')[0];
      const $container = $element.parents('.jsUploadFileContainer');
      $container.find('.jsUploadFileName').text(file.name);
    });
  }
}

export { UploadFileName };

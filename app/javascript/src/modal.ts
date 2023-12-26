import jQuery from 'jquery';

class Modal {
  declare winScrollTop;

  constructor() {
    this.init();
  }

  init() {
    const self = this;
    $('[data-toggle="modal"').each(function() {
      $(this).on('click', self.open);
    });
    jQuery('[data-dismiss="modal"]').on('click', this.close);
  }

  open(e) {
    this.winScrollTop = $(window).scrollTop();
    var target = $(this).data('target');
    var modal = document.getElementById(target);
    $(modal).fadeIn();
    $('.modal').css('height', $(window).height());
    $('.modal-bg').css('height', $(window).height());
    $('.modal-panel').css('height', $(window).height());
    $('body').css('position', 'fixed');
    $('body').css('width', '100%');
  }

  close(e) {
    const target = e.currentTarget.dataset['target'];
    const modal = document.getElementById(target);
    jQuery(modal).fadeOut();
    jQuery('body').css('position', '').css('width', 'initial');
  }
}

export { Modal };

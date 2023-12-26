class ToggleBtn {
  constructor() {
    const self = this;
    jQuery('.jsToggleBox .jsToggleBtn').on('click', function () {
      let toggleBox = $(this).parents('.jsToggleBox');
      let toggleContent = toggleBox.find('.jsToggleContent');
      self.toggle(toggleBox, toggleContent)
    });
  }

  private toggle(toggleBox, toggleContent) {
    if (toggleContent.is(':visible')) {
      this.close(toggleBox, toggleContent)
    } else {
      this.open(toggleBox, toggleContent)
    }
  }

  private open(toggleBox, toggleContent) {
    toggleBox.find('.feather').removeClass('icon-plus-circle').addClass('icon-minus-circle')
    toggleContent.show('slow');
  }

  private close(toggleBox, toggleContent) {
    toggleBox.find('.feather').removeClass('icon-minus-circle').addClass('icon-plus-circle')
    toggleContent.hide('slow');
  }
}

export { ToggleBtn }

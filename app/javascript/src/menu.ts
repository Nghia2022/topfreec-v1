class Menu {
  scrollPos

  constructor() {
    const self = this;
    document.querySelector('.jsSlideMenu')
      .addEventListener('click', () => {
        if (document.querySelector('html').classList.contains('scroll-prevent')) {
          self.close();
        } else {
          self.open();
        }
      });
  }

  open() {
    this.scrollPos = jQuery(window).scrollTop();
    jQuery('.slide-menu').addClass('active');
    jQuery('.menu-trigger').addClass('active');
    jQuery('.jsSlideMenuOpen').addClass('active');
    jQuery('html').addClass('scroll-prevent');
    jQuery('body').css('position', 'fixed');
    jQuery('body').css('width', '100%');
  }

  close() {
    jQuery('.slide-menu').removeClass('active');
    jQuery('.menu-trigger').removeClass('active');
    jQuery('.jsSlideMenuOpen').removeClass('active');
    jQuery('html').removeClass('scroll-prevent');
    jQuery('body').css('position', '');
    jQuery('body').css('width', 'initial');
    jQuery(window).scrollTop(this.scrollPos);
  }
}

export { Menu };

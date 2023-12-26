import jQuery from 'jquery';

class SubNavigation {
  constructor() {
    this.setup();
  }

  setup() {
    jQuery(".jsSubNav")
      .on('mouseenter touchstart', function () {
        jQuery(this).addClass('is-sub-active');
        jQuery(this).children('.jsSubNavOpen').addClass('global-nav-active');
      }).on('mouseleave touchend', function () {
        jQuery(this).removeClass('is-sub-active');
        jQuery(this).children('.jsSubNavOpen').removeClass('global-nav-active');
      });
    jQuery(".jsSubNavSp")
      .on('click', function () {
        jQuery(this).toggleClass('is-sub-active');
        jQuery(this).children('.jsSubNavSpOpen').toggleClass('global-nav-active');
      });
  }
}

export { SubNavigation };

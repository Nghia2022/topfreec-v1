import jQuery from 'jquery';
import 'slick-carousel';

class Carousel {
  constructor() {
    this.setup();
  }

  setup() {
    jQuery('[data-slick]').slick({
      arrows: true,
      autoplay: true,
      autoplaySpeed: 5000,
      dots: true,
      responsive: [{
        breakpoint: 768,
        settings: {
          arrows: false,
          slidesToShow: 1,
          slidesToScroll: 1,
        }
      }]
    });
  }
}

export { Carousel };

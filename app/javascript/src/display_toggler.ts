class DisplayToggler {
  constructor() {
    document.querySelectorAll('[data-toggle="display"]').forEach((container) => {
      this.setupEvents(container);
    });
  }

  setupEvents(container) {
    const togglerOpen = container.querySelector('.display-toggler-open');
    const togglerClose = container.querySelector('.display-toggler-close');
    const target = container.querySelector('.display-target');

    togglerOpen.addEventListener('click', (e) => {
      e.preventDefault();

      togglerOpen.classList.add('s-d-hidden');
      togglerClose.classList.remove('s-d-hidden');
      target.classList.remove('s-d-hidden');
    });

    togglerClose.addEventListener('click', (e) => {
      e.preventDefault();

      togglerOpen.classList.remove('s-d-hidden');
      togglerClose.classList.add('s-d-hidden');
      target.classList.add('s-d-hidden');
    });
  }
}

export { DisplayToggler };

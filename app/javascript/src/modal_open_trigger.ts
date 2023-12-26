import { ToggleBtn } from '../src/toggle_btn';

class ModalOpenTrigger {
  constructor() {
    const target = document.getElementById('jsModal');
    const observer = new MutationObserver(this.callback.bind(this));
    observer.observe(target, this.observerOption());
  }

  private callback(records) {
    this.addToggleBtnEvent(records[records.length -1])
  }

  private addToggleBtnEvent(record) {
    if (record.addedNodes.length) {
      new ToggleBtn();
    }
  }

  private observerOption() {
    return {
      childList: true,
      subtree: true
    }
  }
}

export { ModalOpenTrigger }

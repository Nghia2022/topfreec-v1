import { RemoteModal } from '@/src/remote_modal';
import jQuery from 'jquery';

const modalHtml = require('./modal.html');
const formHtml = require('./form.html');

describe('remote_modal', () => {
  describe('open', () => {
    let modal, onOpen;

    beforeEach(async () => {
      document.body.innerHTML = modalHtml;

      const el = document.querySelector('#modal');
      onOpen = jest.fn();
      modal = new RemoteModal(el, onOpen);
      modal.get = async () => 'fetched';

      await jQuery('.jsModalOpen').click();
    });

    test('open modal', async () => {
      expect(modal.el.innerHTML).toMatch(/fetched/);
      expect(document.body.className).toMatch(/modal-active/);
    });

    test('callback', async () => {
      expect(onOpen).toHaveBeenCalled();
    });
  });

  describe('close', () => {
    let modal;

    beforeEach(async () => {
      document.body.innerHTML = modalHtml;

      const el = document.querySelector('#modal');
      modal = new RemoteModal(el);
      modal.get = async () => 'fetched <div class="jsModalClose">閉じる</div>';

      await jQuery('.jsModalOpen').click();
    });

    test('close modal', async () => {
      expect(modal.el.innerHTML).toMatch(/fetched/);

      await jQuery('.jsModalClose').click();
      await new Promise(resolve => setTimeout(resolve, 300));

      expect(modal.el.innerHTML).toEqual('');
      expect(document.body.className).not.toMatch(/modal-active/);
    });
  });

  describe('onAjaxSuccess', () => {
    let modal;

    beforeEach(async () => {
      jest.setTimeout(8000);

      document.body.innerHTML = modalHtml;

      const el = document.querySelector('#modal');
      modal = new RemoteModal(el);
      modal.get = async () => 'fetched';
      modal.complete = jest.fn();

      await jQuery('.jsModalOpen').click();
    });

    test('reload modal', async () => {
      expect(modal.el.innerHTML).toMatch(/fetched/);
      await jQuery(modal.el).trigger({ type: 'ajax:success', detail: [null, null, 200] } as any);

      await new Promise(resolve => setTimeout(resolve, 6100));
      expect(modal.complete).toHaveBeenCalled();
    });
  });

  describe('onAjaxError', () => {
    let modal;

    beforeEach(async () => {
      document.body.innerHTML = modalHtml;

      const el = document.querySelector('#modal');
      modal = new RemoteModal(el);
      modal.get = async () => '<div class="modal-container">fetched</div>';
      modal.complete = jest.fn();

      await jQuery('.jsModalOpen').click();
    });

    test('display errors', async () => {
      await jQuery(modal.el).trigger({ type: 'ajax:error', detail: ['<div><div class="modal-container">error</div></div>', null, 500] } as any);
      expect(modal.el.innerHTML).toMatch(/error/);
    });
  });
});

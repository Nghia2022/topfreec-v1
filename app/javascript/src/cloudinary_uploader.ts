const { cloudinaryCredentials: { cloudName, apiKey } } = window as any;

class CloudinaryUploader {
  constructor() {
    this.setupEvents();
  }

  setupEvents() {
    jQuery(document).on('change', '.cloudinary-uploader-input', async (e) => {
      const $element = jQuery(e.target);
      const file = $element.prop('files')[0];
      const $container = $element.parents('.cloudinary-uploader');
      const $value = $container.find('.cloudinary-uploader-value');
      const $submit = $container.find('.cloudinary-uploader-submit');
      const $error = $container.find('.cloudinary-uploader-error').html('');
      try {
        const url = await this.upload(file);
        $value.val(url);
        $submit.prop('disabled', false).removeClass('btn-theme-disabled').addClass('btn-theme-02');
      } catch (e) {
        $error.html(`予期せぬエラーが発生しました<br>${e.message}`);
      }
    });
  }

  async upload(file) {
    const timestamp = Math.round(new Date().getTime() / 1000).toString();
    const signature = await this.generateSignature(timestamp);

    const form = new FormData();
    form.append('timestamp', timestamp);
    form.append('signature', signature);
    form.append('api_key', apiKey);
    form.append('file', file);
    const res = await fetch(
      `https://api.cloudinary.com/v1_1/${cloudName}/upload`,
      {
        method: 'POST',
        body: form,
      }
    );
    const data = await res.json();
    if (data.error) {
      throw new Error(data.error.message);
    }
    return data.secure_url;
  }

  async generateSignature(timestamp) {
    const res = await fetch('/api/v1/cloudinary_signatures', {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ params_to_sign: { timestamp } })
    });
    const json = await res.json();
    return json.signature;
  };
}

export { CloudinaryUploader };

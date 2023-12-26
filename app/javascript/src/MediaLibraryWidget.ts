import jQuery from 'jquery';
const { credentials, cloudinary } = window as any;

class MediaLibraryWidget {
  cloudName: string;
  apiKey: string;

  constructor(cloudName, apiKey) {
    this.cloudName = cloudName;
    this.apiKey = apiKey;
    this.setupEvents();
  }

  setupEvents() {
    jQuery(document.body)
    .on('click', '.media-library-trigger', async e => {
      const { cloudName, apiKey } = this;

      e.preventDefault();
      const folder = jQuery(e.target).data('folder');

      cloudinary.openMediaLibrary({
        cloud_name: cloudName,
        api_key: apiKey,
        folder: { path: folder, resource_type: 'image' },
      }, {});
    });
  }
};

export default MediaLibraryWidget;

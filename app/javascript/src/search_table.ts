import jQuery from "jquery";

class SearchTable {
  constructor() {
    this.setup();
  }

  setup() {
    const self = this;
    jQuery(document).ready(function () {
      self.serachBoxViewChange(1);
    });
    jQuery(".jsSearchTableOpen").on("click", function () {
      self.serachBoxViewChange(0);
    });
    jQuery(".jsSearchTableClose").on("click", function () {
      self.serachBoxViewChange(1);
    });
  }

  serachBoxViewChange(num) {
    if (num == 0) {
      jQuery(".jsSearchTableOpen").hide();
      jQuery(".jsSearchTableClose").show();
      jQuery(".jsSearchTable").show();
    } else {
      jQuery(".jsSearchTableOpen").show();
      jQuery(".jsSearchTableClose").hide();
      jQuery(".jsSearchTable").hide();
    }
  }
}

export { SearchTable };

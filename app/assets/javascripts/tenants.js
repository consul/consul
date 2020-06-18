(function() {
  "use strict";
  App.Tenants = {
    initialize: function() {
      return $(".js-tenant-changer").on("change", function() {
        return window.location.assign("/admin/tenants/switch/" + $(this).val());
      });
    }
  };
}).call(this);

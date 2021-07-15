(function() {
  "use strict";
  App.MachineLearning = {
    initialize: function() {
      $("select[class='js-ml-script-select']").on({
        change: function() {
          var script = $(this).val();
          $("#script_descriptions").children("div").each(function() {
            var div = $(this);
            if (div.attr("id") === script) {
              div.removeClass("hide");
            } else {
              div.addClass("hide");
            }
          });
        }
      });
    }
  };
}).call(this);

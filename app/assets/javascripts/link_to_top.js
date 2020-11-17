(function() {
  "use strict";
  App.LinkToTop = {
    initialize: function() {
      $(document).scroll(function() {
        var y = $(this).scrollTop();
        var link_to_top_scroll = $(window).height() * 20 / 100;
        if (y > link_to_top_scroll) {
          $(".link-to-top").fadeIn();
        } else {
          $(".link-to-top").fadeOut();
        }
      });
    }
  };
}).call(this);

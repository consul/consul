(function() {
  "use strict";
  App.LocaleSwitcher = {
    initialize: function() {
      $(".locale-switcher").each(function() {
        var button = $(this).find("[role='menuitem']:first");

        $(this).find("p").on("click", function(event) {
          event.stopPropagation();
          button.focus();
        });

        button.on("keydown", function(event) {
          if (event.keyCode === 40) {
            event.preventDefault();
            event.stopPropagation();
            $(this).trigger($.Event("keydown", { keyCode: 39 }));
          }
        });

        $(this).on("show.zf.dropdownMenu", function() {
          $(this).find("[aria-current='true'] a").focus()[0].scrollIntoView({ block: "nearest" });
        });

        $(this).find("ul ul").on("keydown", function(event) {
          App.LocaleSwitcher.focusElementStartingWith(String.fromCharCode(event.which));
        });
      });
    },
    focusElementStartingWith: function(character) {
      var active_item = $(document.activeElement).parent();

      var match = App.LocaleSwitcher.firstStartingWith(active_item.nextAll(), character) ||
        App.LocaleSwitcher.firstStartingWith(active_item.siblings(), character);

      if (match) {
        match.querySelector("a").focus();
      }
    },
    firstStartingWith: function(elements, character) {
      return elements.filter(function() {
        return $(this).text().trim()[0].toUpperCase() === character.toUpperCase();
      })[0];
    }
  };
}).call(this);


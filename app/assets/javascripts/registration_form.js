(function() {
  "use strict";
  App.RegistrationForm = {
    initialize: function() {
      var clearUsernameMessage, showUsernameMessage, usernameInput, validateUsername;
      usernameInput = $("form#new_user[action=\"/users\"] input#user_username");
      clearUsernameMessage = function() {
        $("small").remove();
      };
      showUsernameMessage = function(response) {
        var klass;
        klass = response.available ? "no-error" : "error";
        usernameInput.after($("<small class=\"" + klass + "\" style=\"margin-top: -16px;\">" + response.message + "</small>"));
      };
      validateUsername = function(username) {
        var request;
        request = $.get("/user/registrations/check_username?username=" + username);
        request.done(function(response) {
          showUsernameMessage(response);
        });
      };
      usernameInput.on("focusout", function() {
        var username;
        clearUsernameMessage();
        username = usernameInput.val();
        if (username !== "") {
          validateUsername(username);
        }
      });
      var clearEmailMessage, showEmailMessage, emailInput, validateEmail;
      emailInput = $("form#new_user[action=\"/users\"] input#user_email");
      clearEmailMessage = function() {
        $("small").remove();
      };
      showEmailMessage = function(response) {
        var klass;
        klass = response.available ? "no-error" : "error";
        emailInput.after($("<small class=\"" + klass + "\" style=\"margin-top: -16px;\">" + response.message + "</small>"));
      };
      validateEmail = function(email) {
        var request;
        request = $.get("/user/registrations/check_email?email=" + email);
        request.done(function(response) {
          showEmailMessage(response);
        });
      };
      emailInput.on("focusout", function() {
        var email;
        clearEmailMessage();
        email = emailInput.val();
        if (email !== "") {
          validateEmail(email);
        }
      });
    }
  };
}).call(this);

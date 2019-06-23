// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui/widgets/datepicker
//= require jquery-ui/i18n/datepicker-es
//= require jquery-ui/widgets/autocomplete
//= require jquery-ui/widgets/sortable
//= require jquery-fileupload/basic
//= require foundation
//= require turbolinks
//= require ckeditor/loader
//= require_directory ./ckeditor
//= require social-share-button
//= require initial
//= require ahoy
//= require app
//= require check_all_none
//= require comments
//= require foundation_extras
//= require ie_alert
//= require location_changer
//= require moderator_comment
//= require moderator_debates
//= require moderator_proposals
//= require moderator_budget_investments
//= require moderator_proposal_notifications
//= require prevent_double_submission
//= require gettext
//= require annotator
//= require tags
//= require users
//= require votes
//= require allow_participation
//= require annotatable
//= require advanced_search
//= require registration_form
//= require suggest
//= require forms
//= require tracks
//= require valuation_budget_investment_form
//= require embed_video
//= require fixed_bar
//= require banners
//= require social_share
//= require checkbox_toggle
//= require markdown-it
//= require markdown_editor
//= require cocoon
//= require answers
//= require questions
//= require legislation_admin
//= require legislation
//= require legislation_allegations
//= require legislation_annotatable
//= require watch_form_changes
//= require followable
//= require flaggable
//= require documentable
//= require imageable
//= require tree_navigator
//= require custom
//= require tag_autocomplete
//= require polls_admin
//= require leaflet
//= require leaflet.markercluster
//= require map
//= require polls
//= require sortable
//= require table_sortable
//= require investment_report_alert
//= require send_newsletter_alert
//= require managers
//= require globalize
//= require send_admin_notification_alert
//= require modal_download
//= require settings
//= require cookies
//= require columns_selector
//= require budget_edit_associations.js.coffee
//= require votations

var initialize_modules = function() {
  App.Answers.initialize();
  App.Questions.initialize();
  App.Comments.initialize();
  App.Users.initialize();
  App.Votes.initialize();
  App.AllowParticipation.initialize();
  App.Tags.initialize();
  App.FoundationExtras.initialize();
  App.LocationChanger.initialize();
  App.CheckAllNone.initialize();
  App.PreventDoubleSubmission.initialize();
  App.IeAlert.initialize();
  App.Annotatable.initialize();
  App.AdvancedSearch.initialize();
  App.RegistrationForm.initialize();
  App.Suggest.initialize();
  App.Forms.initialize();
  App.Tracks.initialize();
  App.ValuationBudgetInvestmentForm.initialize();
  App.EmbedVideo.initialize();
  App.FixedBar.initialize();
  App.Banners.initialize();
  App.SocialShare.initialize();
  App.CheckboxToggle.initialize();
  App.MarkdownEditor.initialize();
  App.LegislationAdmin.initialize();
  App.LegislationAllegations.initialize();
  App.Legislation.initialize();
  if ( $(".legislation-annotatable").length )
    App.LegislationAnnotatable.initialize();
  App.WatchFormChanges.initialize();
  App.TreeNavigator.initialize();
  App.Documentable.initialize();
  App.Imageable.initialize();
  App.TagAutocomplete.initialize();
  App.PollsAdmin.initialize();
  App.Map.initialize();
  App.Polls.initialize();
  App.Sortable.initialize();
  App.TableSortable.initialize();
  App.InvestmentReportAlert.initialize();
  App.SendNewsletterAlert.initialize();
  App.Managers.initialize();
  App.Globalize.initialize();
  App.SendAdminNotificationAlert.initialize();
  App.ModalDownload.initialize();
  App.Settings.initialize();
  App.Cookies.initialize();
  if ( $('#js-columns-selector').length )
    App.ColumnsSelector.initialize();
  App.BudgetEditAssociations.initialize();
  if ( $("#votation_type_enum_type").length )
    App.Votations.initialize();
};

$(function(){
  Turbolinks.enableProgressBar();

  $(document).ready(initialize_modules);
  $(document).on("page:load", initialize_modules);
  $(document).on("ajax:complete", initialize_modules);
});

App.Tracks =

  tracking_enabled: ->
    _paq?

  track_current_page: ->
    _paq.push(['setCustomUrl',   window.location.href])
    _paq.push(['setReferrerUrl', document.referrer])
    _paq.push(['trackPageView',  App.Tracks.page_title()])

  track_event: ($this) ->
    category = $this.data('track-event-category')
    action   = $this.data('track-event-action')
    name     = $this.data('track-event-name')
    _paq.push(['trackEvent', category, action, name])

  proposal_show_page: ->
    $("#js-tracking").data('proposal-show')

  track_proposal: ->
    page_title = App.Tracks.page_title()
    proposal_rank = $('#js-tracking').data('proposal-rank')
    _paq.push(['trackPageView', page_title, {dimension6: proposal_rank}])

  track_user: ->
    tracking_data      = $("meta[name='tracking_data']")
    current_user_id    = tracking_data.data('track-user-id')
    verification_level = tracking_data.data('track-verification-level')
    sex                = tracking_data.data('track-track-gender')
    age                = tracking_data.data('track-age')
    district           = tracking_data.data('track-district')

    _paq.push(['setCustomDimension', customDimensionId = 1, customDimensionValue = verification_level]);
    if current_user_id?
      _paq.push(['setUserId', current_user_id]);
      _paq.push(['setCustomDimension', customDimensionId = 2, customDimensionValue = current_user_id])
      _paq.push(['setCustomDimension', customDimensionId = 3, customDimensionValue = sex])
      _paq.push(['setCustomDimension', customDimensionId = 4, customDimensionValue = age])
      _paq.push(['setCustomDimension', customDimensionId = 5, customDimensionValue = district])

  page_title: ->
    $(document).find("title").text()

  initialize: ->
    if App.Tracks.tracking_enabled()

      if App.Tracks.proposal_show_page()
        App.Tracks.track_proposal()

      $('[data-track-event-category]').each ->
        $this = $(this)
        App.Tracks.track_event($this)

      App.Tracks.track_user()
      App.Tracks.track_current_page()
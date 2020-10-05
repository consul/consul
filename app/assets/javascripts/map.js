(function() {
  "use strict";
  App.Map = {
    maps: [],
    initialize: function() {
      $("*[data-map]:visible").each(function() {
        App.Map.initializeMap(this);
      });
      $(".js-toggle-map").on({
        click: function() {
          App.Map.toggleMap();
        }
      });
    },
    destroy: function() {
      App.Map.maps.forEach(function(map) {
        map.off();
        map.remove();
      });
      App.Map.maps = [];
    },
    initializeMap: function(element) {
      var addGeographyPolygons, addMarkerInvestments, clearFormfields, createMarker, createPolygon,
        dataCoordinates, editable, formCoordinates, getPopupContent, latitudeInputSelector,
        longitudeInputSelector, map, mapAttribution, mapCenterLatLng, mapCenterLatitude, mapCenterLongitude,
        mapTilesProvider, marker, markerIcon, markerLatitude, markerLongitude, moveOrPlaceMarker,
        openMarkerPopup, openPolygonPopup, removeMarker, removeMarkerSelector, updateFormfields, zoom,
        zoomInputSelector;

      App.Map.cleanInvestmentCoordinates(element);
      mapTilesProvider = $(element).data("map-tiles-provider");
      mapAttribution = $(element).data("map-tiles-provider-attribution");
      latitudeInputSelector = $(element).data("latitude-input-selector");
      longitudeInputSelector = $(element).data("longitude-input-selector");
      zoomInputSelector = $(element).data("zoom-input-selector");
      formCoordinates = {
        lat: $(latitudeInputSelector).val(),
        long: $(longitudeInputSelector).val(),
        zoom: $(zoomInputSelector).val()
      };
      dataCoordinates = {
        lat: $(element).data("marker-latitude"),
        long: $(element).data("marker-longitude")
      };
      if (App.Map.validCoordinates(formCoordinates)) {
        markerLatitude = formCoordinates.lat;
        markerLongitude = formCoordinates.long;
        mapCenterLatitude = formCoordinates.lat;
        mapCenterLongitude = formCoordinates.long;
      } else if (App.Map.validCoordinates(dataCoordinates)) {
        markerLatitude = dataCoordinates.lat;
        markerLongitude = dataCoordinates.long;
        mapCenterLatitude = dataCoordinates.lat;
        mapCenterLongitude = dataCoordinates.long;
      } else {
        mapCenterLatitude = $(element).data("map-center-latitude");
        mapCenterLongitude = $(element).data("map-center-longitude");
      }
      if (App.Map.validZoom(formCoordinates.zoom)) {
        zoom = formCoordinates.zoom;
      } else {
        zoom = $(element).data("map-zoom");
      }
      removeMarkerSelector = $(element).data("marker-remove-selector");
      addMarkerInvestments = $(element).data("marker-investments-coordinates");
      addGeographyPolygons = $(element).data("polygons-geographies-data");
      editable = $(element).data("marker-editable");
      marker = null;
      markerIcon = L.divIcon({
        className: "map-marker",
        iconSize: [30, 30],
        iconAnchor: [15, 40],
        html: '<div class="map-icon"></div>'
      });
      createMarker = function(latitude, longitude) {
        var markerLatLng;
        markerLatLng = new L.LatLng(latitude, longitude);
        marker = L.marker(markerLatLng, {
          icon: markerIcon,
          draggable: editable
        });
        if (editable) {
          marker.on("dragend", updateFormfields);
        }
        marker.addTo(map);
        return marker;
      };
      createPolygon = function(polygon_data) {
        var polygon;
        polygon = L.polygon(polygon_data.outline_points, {
          color: polygon_data.color
        });
        if (polygon_data.headings.length > 0) {
          polygon.on("click", openPolygonPopup);
          polygon.options.headings = polygon_data.headings;
          polygon.options.fillOpacity = 0.3;
        } else {
          polygon.options.fillOpacity = 0;
        }
        polygon.addTo(map);
        return polygon;
      };
      removeMarker = function(e) {
        e.preventDefault();
        if (marker) {
          map.removeLayer(marker);
          marker = null;
        }
        clearFormfields();
      };
      moveOrPlaceMarker = function(e) {
        if (marker) {
          marker.setLatLng(e.latlng);
        } else {
          marker = createMarker(e.latlng.lat, e.latlng.lng);
        }
        updateFormfields();
      };
      updateFormfields = function() {
        $(latitudeInputSelector).val(marker.getLatLng().lat);
        $(longitudeInputSelector).val(marker.getLatLng().lng);
        $(zoomInputSelector).val(map.getZoom());
      };
      clearFormfields = function() {
        $(latitudeInputSelector).val("");
        $(longitudeInputSelector).val("");
        $(zoomInputSelector).val("");
      };
      openMarkerPopup = function(e) {
        marker = e.target;
        $.ajax("/investments/" + marker.options.id + "/json_data", {
          type: "GET",
          dataType: "json",
          success: function(data) {
            e.target.bindPopup(getPopupContent(data)).openPopup();
          }
        });
      };
      getPopupContent = function(data) {
        return "<a href='/budgets/" + data.budget_id + "/investments/" + data.investment_id + "'>" + data.investment_title + "</a>";
      };
      openPolygonPopup = function(e) {
        var polygon = e.target;
        if (polygon.options.headings.length > 0) {
          var data = polygon.options.headings.map(function(heading) {
            return heading + "<br>";
          });
          return e.target.bindPopup(data.join("").slice(0, -4)).openPopup();
        }
      };
      mapCenterLatLng = new L.LatLng(mapCenterLatitude, mapCenterLongitude);
      map = L.map(element.id).setView(mapCenterLatLng, zoom);
      App.Map.maps.push(map);
      L.tileLayer(mapTilesProvider, {
        attribution: mapAttribution
      }).addTo(map);
      if (markerLatitude && markerLongitude && !addMarkerInvestments) {
        marker = createMarker(markerLatitude, markerLongitude);
      }
      if (editable) {
        $(removeMarkerSelector).on("click", removeMarker);
        map.on("zoomend", function() {
          if (marker) {
            updateFormfields();
          }
        });
        map.on("click", moveOrPlaceMarker);
      }
      if (addMarkerInvestments) {
        addMarkerInvestments.forEach(function(coordinates) {
          if (App.Map.validCoordinates(coordinates)) {
            marker = createMarker(coordinates.lat, coordinates.long);
            marker.options.id = coordinates.investment_id;
            marker.on("click", openMarkerPopup);
          }
        });
      }
      if (addGeographyPolygons) {
        for (var i = 0; i < addGeographyPolygons.length; i++) {
          createPolygon(addGeographyPolygons[i]);
        }
      }
    },
    toggleMap: function() {
      $(".map").toggle();
      $(".js-location-map-remove-marker").toggle();
    },
    cleanInvestmentCoordinates: function(element) {
      var clean_markers, markers;
      markers = $(element).attr("data-marker-investments-coordinates");
      if (markers != null) {
        clean_markers = markers.replace(/-?(\*+)/g, null);
        $(element).attr("data-marker-investments-coordinates", clean_markers);
      }
    },
    validZoom: function(zoom) {
      return App.Map.isNumeric(zoom);
    },
    validCoordinates: function(coordinates) {
      return App.Map.isNumeric(coordinates.lat) && App.Map.isNumeric(coordinates.long);
    },
    isNumeric: function(n) {
      return !isNaN(parseFloat(n)) && isFinite(n);
    }
  };
}).call(this);

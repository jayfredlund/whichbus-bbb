define ['whichbus', 'geocode'], (WhichBus, Geocode) ->
	# Geocode.initialize(WhichBus.map.map)
	class WhichBus.Models.Itinerary extends Backbone.Model
		summary: ->
			_.pluck(_.filter(@get('legs'), (leg) -> leg.mode not in ['WALK', 'BIKE']), 'route').join(', ')

		summaryHTML: ->
			index = 0
			stops = _.map(_.filter(@get('legs'), (leg) -> leg.mode not in ['WALK', 'BIKE']), (leg) -> 
				index++
				expandable = if index > 2 then ' expandable' else ''
				route = if leg.mode == 'FERRY' then 'FERRY' else leg.route
				"<span class='btn btn-route#{expandable}'>#{route}</span>"
			).join(' ')
			stops = "#{stops} <span class='btn btn-route expand'>+#{index-2}</span>" if index > 2
			return stops

		timing: ->
			start = WhichBus.format_time(@get('startTime'))
			end   = WhichBus.format_time(@get('endTime'))
			total = WhichBus.format_duration(@get('duration') / 1000)
			"#{start}–#{end} (#{total})"

		duration: ->
			walk = WhichBus.format_duration(@get('walkTime'), true)
			wait = WhichBus.format_duration(@get('waitingTime'), true)
			bus =  WhichBus.format_duration(@get('transitTime'), true)
			"#{walk} walking, #{bus} transit"

		bounds: ->
			# create and cache bounds surrounding all points in leg geometry
			unless @get 'bounds'
				bounds = new google.maps.LatLngBounds()
				for leg in @get('legs')
					for point in google.maps.geometry.encoding.decodePath(leg.legGeometry.points)
						bounds.extend(point)
				@set 'bounds', bounds
			@get 'bounds'

	class WhichBus.Collections.Itineraries extends Backbone.Collection
		model: WhichBus.Models.Itinerary
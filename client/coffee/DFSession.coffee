###
	Class representing a recording session in Digital Fortress

	Note: This class manages all data sources for a session
	(i.e. video, audio, geolocation, etc.) 
###

class @DFSession

	######################################################################

	constructor: ->
		@dfstreamer = null
		@sessionId = Random.id()
		@startTime = null
		@endTime = null

	start: =>
		@dfstreamer = new DFStreamer
		@dfstreamer.start()

	onCamPermissionReceived: =>
		DF.setIsRecording true
		props = @getProperties()
		Meteor.call 'createSessionOnServer', props, (error, result) =>
			@startTime = result?.startTime

	stop: =>
		@dfstreamer.stop()
		@dfstreamer = null
		DF.setIsRecording false

		props = @getProperties()
		Meteor.call 'endSessionOnServer', props, (error, result) =>
			@endTime = result?.endTime

	getProperties: =>
		return {
			@sessionId
			@startTime
			@endTime
			@captures
			@locations
			@audio
		}
	
	# Whenever movement is detected (called from DFStreamer)...
	onMovementDetected: =>
		
		# If called for, save the current image
		if DF.isRecording() and DF.saveImages()

			# Stop saving images
			DF.setSaveImages false

			# Get the image buffer
			dataURL = @dfstreamer.currCanvas.toDataURL 'image/png'

			# Create the capture
			capture = {
				'uid': Meteor.userId()
				'sessionId': @sessionId
				'date': new Date()
				'fileId': ''
				'filename': Random.id() + '.png'
				'source': AppConfig.LOADING_SPINNER
			}

			# Save the capture
			Captures.insert(capture)

			# Save the image
			Meteor.call 'saveImage', dataURL, capture

			Meteor.setTimeout (-> DF.setSaveImages true), (AppConfig.IMAGE_DELAY * 1000)

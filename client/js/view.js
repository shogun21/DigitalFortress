// Digital Fortress -- view

///////////////////////////////////////////////////////////////////////////////
// View Template - Helpers

Template.view.helpers({

	captures: function() {
		return Meteor.user().profile.captures;
	}
});

///////////////////////////////////////////////////////////////////////////////
// View Template - Events

Template.view.events({

	// Nothing yet
});
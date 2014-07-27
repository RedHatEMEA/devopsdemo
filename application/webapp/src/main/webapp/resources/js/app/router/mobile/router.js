/**
 * A module for the router of the mobile application.
 *
 */
define("router",[
    'jquery',
    'jquerymobile',
    'underscore',
    'utilities',
    'app/models/booking',
    'app/models/event',
    'app/models/venue',
    'app/collections/bookings',
    'app/collections/events',
    'app/collections/venues',
    'app/views/mobile/about',
    'app/views/mobile/events',
    'app/views/mobile/venues',
    'app/views/mobile/create-booking',
    'app/views/mobile/bookings',
    'app/views/mobile/event-detail',
    'app/views/mobile/venue-detail',
    'app/views/mobile/booking-detail',
    'text!../templates/mobile/home-view.html'
],function ($,
            jqm,
            _,
            utilities,
            Booking,
            Event,
            Venue,
            Bookings,
            Events,
            Venues,
            AboutView,
            EventsView,
            VenuesView,
            CreateBookingView,
            BookingsView,
            EventDetailView,
            VenueDetailView,
            BookingDetailView,
            HomeViewTemplate) {

    /**
     * The Router class contains all the routes within the application - i.e. URLs and the actions
     * that will be taken as a result.
     *
     * @type {Router}
     */
    var Router = Backbone.Router.extend({
    	initialize: function() {
            //Begin dispatching routes
    		Backbone.history.start();
    	},
        routes:{
            "":"home",
            "events":"events",
            "events/:id":"eventDetail",
            "venues":"venues",
            "venues/:id":"venueDetail",
            "about":"about",
            "book/:showId/:performanceId":"bookTickets",
            "bookings":"listBookings",
            "bookings/:id":"bookingDetail",
            "ignore":"ignore",
            "*actions":"defaultHandler"
        },
        defaultHandler:function (actions) {
            if ("" != actions) {
                $("body").pagecontainer( "change", "#" + actions, {transition:'slide', changeHash:false, allowSamePageTransition:true});
            }
        },
        home:function () {
            utilities.applyTemplate($("#container"), HomeViewTemplate);
            try {
                $("#container").enhanceWithin();
            } catch (e) {
                // workaround for a spurious error thrown when creating the page initially
            }
        },
        events:function () {
            var events = new Events;
            var eventsView = new EventsView({model:events, el:$("#container")});
            events.on("reset", function() {
                utilities.viewManager.showView(eventsView);
            }).fetch({
                reset : true,
                error : function() {
                    utilities.displayAlert("Failed to retrieve events from the TicketMonster server.");
                }
            });
        },
        venues:function () {
            var venues = new Venues;
            var venuesView = new VenuesView({model:venues, el:$("#container")});
            venues.on("reset",
                function () {
                    utilities.viewManager.showView(venuesView);
                }).fetch({
                    reset : true,
                    error : function() {
                        utilities.displayAlert("Failed to retrieve venues from the TicketMonster server.");
                    }
                });
        },
        about:function () {
            new AboutView({el:$("#container")}).render();
        },
        bookTickets:function (showId, performanceId) {
            var createBookingView = new CreateBookingView({model:{showId:showId, performanceId:performanceId, bookingRequest:{tickets:[]}}, el:$("#container")});
            utilities.viewManager.showView(createBookingView);
        },
        listBookings:function () {
            var bookings = new Bookings();
            var bookingsView = new BookingsView({model:bookings, el:$("#container")});
            bookings.on("reset",
                function () {
                    utilities.viewManager.showView(bookingsView);
                }).on("destroy",
                function () {
                    this.fetch({
                        reset : true,
                        error : function() {
                            utilities.displayAlert("Failed to retrieve bookings from the TicketMonster server.");
                        }
                    });
                }).fetch({
                    reset : true,
                    error : function() {
                        utilities.displayAlert("Failed to retrieve bookings from the TicketMonster server.");
                    }
                });
        },
        eventDetail:function (id) {
            var model = new Event({id:id});
            var eventDetailView = new EventDetailView({model:model, el:$("#container")});
            model.on("change",
                function () {
                    utilities.viewManager.showView(eventDetailView);
                    $("body").pagecontainer("change", "#container", {transition:'slide', changeHash:false});
                }).fetch({
                    error : function() {
                        utilities.displayAlert("Failed to retrieve the event from the TicketMonster server.");
                    }
                });
        },
        venueDetail:function (id) {
            var model = new Venue({id:id});
            var venueDetailView = new VenueDetailView({model:model, el:$("#container")});
            model.on("change",
                function () {
                    utilities.viewManager.showView(venueDetailView);
                    $("body").pagecontainer("change", "#container", {transition: 'slide', changeHash: false});
                }).fetch({
                    error : function() {
                        utilities.displayAlert("Failed to retrieve the venue from the TicketMonster server.");
                    }
                });
        },
        bookingDetail:function (id) {
            var bookingModel = new Booking({id:id});
            var bookingDetailView = new BookingDetailView({model:bookingModel, el:$("#content")});
            bookingModel.on("change",
                function () {
                    utilities.viewManager.showView(bookingDetailView);
                }).fetch({
                    error : function() {
                        utilities.displayAlert("Failed to retrieve the booking from the TicketMonster server.");
                    }
                });
        }
    });
    
    // Create a router instance
    var router = new Router();
    
    return router;
});
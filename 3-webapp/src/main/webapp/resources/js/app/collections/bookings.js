/**
 * The module for a collection of Bookings
 */
define([
    'app/models/booking',
    'configuration',
    'backbone'
], function (Booking, config) {

    // Here we define the Bookings collection
    // We will use it for CRUD operations on Bookings

    var Bookings = Backbone.Collection.extend({
        url: config.baseUrl + 'rest/bookings',
        model: Booking,
        id:'id'
    });

    return Bookings;
});
/**
 * The module for a collection of Venues
 */
define([
    // Configuration and the collection element type are dependencies
    'app/models/venue',
    'configuration',
    'backbone'
], function (Venue, config) {

    return Backbone.Collection.extend({
        url: config.baseUrl + "rest/venues",
        model:Venue,
        id:"id",
        comparator:function (model) {
            return model.get('address').city;
        }
    });
});
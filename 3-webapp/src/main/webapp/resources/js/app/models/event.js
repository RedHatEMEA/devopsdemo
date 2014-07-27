/**
 * Module for the Event model
 */
define([ 
    'configuration',
    'backbone'
], function (config) {
    /**
     * The Event model class definition
     * Used for CRUD operations against individual events
     */
    var Event = Backbone.Model.extend({
        urlRoot: config.baseUrl + 'rest/events' // the URL for performing CRUD operations
    });
    // export the Event class
    return Event;
});
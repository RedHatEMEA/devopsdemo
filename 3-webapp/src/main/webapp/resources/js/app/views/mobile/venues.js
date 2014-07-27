define([
    'utilities',
    'text!../../../../templates/mobile/venues.html'
], function (
    utilities,
    venuesView) {

    var EventsView = Backbone.View.extend({
        render:function () {
            var cities = _.uniq(
                _.map(this.model.models, function(model){
                    return model.get('address').city
                }));
            utilities.applyTemplate($(this.el), venuesView,  {cities:cities, model:this.model})
            $(this.el).enhanceWithin();
            return this;
        }
    });

    return EventsView;
});
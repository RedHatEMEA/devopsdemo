define([
    'utilities',
    'text!../../../../templates/mobile/events.html'
], function (
    utilities,
    eventsView) {

    var EventsView = Backbone.View.extend({
        render:function () {
            var categories = _.uniq(
                _.map(this.model.models, function(model){
                    return model.get('category')
                }), false, function(item){
                    return item.id
                });
            utilities.applyTemplate($(this.el), eventsView,  {categories:categories, model:this.model})
            $(this.el).enhanceWithin();
            return this;
        }
    });

    return EventsView;
});
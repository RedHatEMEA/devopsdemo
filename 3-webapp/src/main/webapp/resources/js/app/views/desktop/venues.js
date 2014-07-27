define([
    'utilities',
    'configuration',
    'text!../../../../templates/desktop/venues.html'
], function (
    utilities,
    config,
    venuesTemplate) {

    var EventsView = Backbone.View.extend({
        events:{
            "click a":"update"
        },
        render:function () {
            var cities = _.uniq(
                _.map(this.model.models, function(model){
                    return model.get('address').city
                }));
            utilities.applyTemplate($(this.el), venuesTemplate, {cities: cities, model:this.model, config:config});
            $(this.el).find('.item:first').addClass('active');
            $(".carousel").carousel();
            $("a[rel='popover']").popover({trigger:'hover',container:'#content'});
            return this;
        },
        update:function () {
            $("a[rel='popover']").popover('hide')
        }
    });

    return  EventsView;
});

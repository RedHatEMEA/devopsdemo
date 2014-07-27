define([
    'utilities',
    'configuration',
    'require',
    'text!../../../../templates/desktop/venue-detail.html',
    'text!../../../../templates/desktop/media.html',
    'text!../../../../templates/desktop/venue-event-description.html',
    'bootstrap'
], function (
    utilities,
    config,
    require,
    venueDetailTemplate,
    mediaTemplate,
    venueEventDescriptionTemplate) {

    var VenueDetailView = Backbone.View.extend({
        events:{
            "click input[name='bookButton']":"beginBooking",
            "change select[id='eventSelector']":"refreshShows",
            "change select[id='dayPicker']":"refreshTimes"
        },
        render:function () {
            $(this.el).empty()
            utilities.applyTemplate($(this.el), venueDetailTemplate, {attributes:this.model.attributes, config:config})
            $("#eventSelector").attr('disabled', true)
            $("#bookingOption").hide()
            $("#dayPicker").empty()
            $("#dayPicker").attr('disabled', true)
            $("#performanceTimes").empty()
            $("#performanceTimes").attr('disabled', true)
            var self = this
            $.getJSON(config.baseUrl + "rest/shows?venue=" + this.model.get('id'), function (shows) {
                self.shows = shows
                $("#eventSelector").empty().append("<option value='0' selected>Select an event</option>");
                $.each(shows, function (i, show) {
                    $("#eventSelector").append("<option value='" + show.id + "'>" + show.event.name + "</option>")
                })
                $("#eventSelector").removeAttr('disabled')
            });
            return this;
        },
        beginBooking:function () {
            require("router").navigate('/book/' + $("#eventSelector option:selected").val() + '/' + $("#performanceTimes").val(), true)
        },
        refreshShows:function (event) {
            event.stopPropagation();
            $("#dayPicker").empty();
            var selectedShowId = event.currentTarget.value;
            if (selectedShowId != 0) {
                var selectedShow = _.find(this.shows, function (show) {
                    return show.id == selectedShowId
                });
                this.selectedShow = selectedShow;
                utilities.applyTemplate($("#venueEventDescription"), venueEventDescriptionTemplate, {event:selectedShow.event});
                var times = _.uniq(_.sortBy(_.map(selectedShow.performances, function (performance) {
                    return (new Date(performance.date).withoutTimeOfDay()).getTime()
                }), function (item) {
                    return item
                }));
                utilities.applyTemplate($("#eventMedia"), mediaTemplate, {item: selectedShow.event, config: config})
                $("#dayPicker").removeAttr('disabled')
                $("#performanceTimes").removeAttr('disabled')
                _.each(times, function (time) {
                    var date = new Date(time)
                    $("#dayPicker").append("<option value='" + date.toYMD() + "'>" + date.toPrettyStringWithoutTime() + "</option>")
                })
                $("#bookingWhen").show(100)
                this.refreshTimes()
            } else {
                $("#bookingWhen").hide(100)
                $("#bookingOption").hide()
                $("#dayPicker").empty()
                $("#eventMedia").empty()
                $("#venueEventDescription").empty()
                $("#dayPicker").attr('disabled', true)
                $("#performanceTimes").empty()
                $("#performanceTimes").attr('disabled', true)
            }

        },
        refreshTimes:function () {
            var selectedDate = $("#dayPicker").val();
            $("#performanceTimes").empty()
            if (selectedDate) {
                $.each(this.selectedShow.performances, function (i, performance) {
                    var performanceDate = new Date(performance.date);
                    if (_.isEqual(performanceDate.toYMD(), selectedDate)) {
                        $("#performanceTimes").append("<option value='" + performance.id + "'>" + performanceDate.getHours().toZeroPaddedString(2) + ":" + performanceDate.getMinutes().toZeroPaddedString(2) + "</option>")
                    }
                })
            }
            $("#bookingOption").show()
        }

    });

    return  VenueDetailView

});

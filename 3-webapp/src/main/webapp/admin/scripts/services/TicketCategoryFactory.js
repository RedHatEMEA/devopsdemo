angular.module('ticketmonster').factory('TicketCategoryResource', function($resource){
    var resource = $resource('../rest/ticketcategories/:TicketCategoryId',{TicketCategoryId:'@id'},{'queryAll':{method:'GET',isArray:true},'query':{method:'GET',isArray:false},'update':{method:'PUT'}});
    return resource;
});
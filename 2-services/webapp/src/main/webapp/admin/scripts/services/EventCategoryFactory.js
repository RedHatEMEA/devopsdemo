angular.module('ticketmonster').factory('EventCategoryResource', function($resource){
    var resource = $resource('../rest/eventcategories/:EventCategoryId',{EventCategoryId:'@id'},{'queryAll':{method:'GET',isArray:true},'query':{method:'GET',isArray:false},'update':{method:'PUT'}});
    return resource;
});
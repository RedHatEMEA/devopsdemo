package org.jboss.jdf.example.ticketmonster.rest;

import java.util.ArrayList;
import java.util.List;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.PersistenceContext;
import javax.persistence.TypedQuery;
import javax.ws.rs.*;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;
import javax.ws.rs.core.UriBuilder;
import org.jboss.jdf.example.ticketmonster.rest.dto.EventCategoryDTO;
import org.jboss.jdf.example.ticketmonster.model.EventCategory;

/**
 * 
 */
@Stateless
@Path("/eventcategories")
public class EventCategoryEndpoint
{
   @PersistenceContext(unitName="primary")
   private EntityManager em;

   @POST
   @Consumes("application/json")
   public Response create(EventCategoryDTO dto)
   {
      EventCategory entity = dto.fromDTO(null, em);
      em.persist(entity);
      return Response.created(UriBuilder.fromResource(EventCategoryEndpoint.class).path(String.valueOf(entity.getId())).build()).build();
   }

   @DELETE
   @Path("/{id:[0-9][0-9]*}")
   public Response deleteById(@PathParam("id") Long id)
   {
      EventCategory entity = em.find(EventCategory.class, id);
      if (entity == null) {
        return Response.status(Status.NOT_FOUND).build();
      }
      em.remove(entity);
      return Response.noContent().build();
   }

   @GET
   @Path("/{id:[0-9][0-9]*}")
   @Produces("application/json")
   public Response findById(@PathParam("id") Long id)
   {
      TypedQuery<EventCategory> findByIdQuery = em.createQuery("SELECT DISTINCT e FROM EventCategory e WHERE e.id = :entityId ORDER BY e.id", EventCategory.class);
      findByIdQuery.setParameter("entityId", id);
      EventCategory entity;
      try {
         entity = findByIdQuery.getSingleResult();
      } catch (NoResultException nre) {
         entity = null;
      }
      if (entity == null) {
        return Response.status(Status.NOT_FOUND).build();
      }
      EventCategoryDTO dto = new EventCategoryDTO(entity);
      return Response.ok(dto).build();
   }

   @GET
   @Produces("application/json")
   public List<EventCategoryDTO> listAll(@QueryParam("start") Integer startPosition, @QueryParam("max") Integer maxResult)
   {
      TypedQuery<EventCategory> findAllQuery = em.createQuery("SELECT DISTINCT e FROM EventCategory e ORDER BY e.id", EventCategory.class);
      if (startPosition != null)
      {
         findAllQuery.setFirstResult(startPosition);
      }
      if (maxResult != null)
      {
         findAllQuery.setMaxResults(maxResult);
      }
      final List<EventCategory> searchResults = findAllQuery.getResultList();
      final List<EventCategoryDTO> results = new ArrayList<EventCategoryDTO>();
      for(EventCategory searchResult: searchResults) {
        EventCategoryDTO dto = new EventCategoryDTO(searchResult);
        results.add(dto);
      }
      return results;
   }

   @PUT
   @Path("/{id:[0-9][0-9]*}")
   @Consumes("application/json")
   public Response update(@PathParam("id") Long id, EventCategoryDTO dto)
   {
      TypedQuery<EventCategory> findByIdQuery = em.createQuery("SELECT DISTINCT e FROM EventCategory e WHERE e.id = :entityId ORDER BY e.id", EventCategory.class);
      findByIdQuery.setParameter("entityId", id);
      EventCategory entity;
      try {
         entity = findByIdQuery.getSingleResult();
      } catch (NoResultException nre) {
         entity = null;
      }
      entity = dto.fromDTO(entity, em);
      entity = em.merge(entity);
      return Response.noContent().build();
   }
}
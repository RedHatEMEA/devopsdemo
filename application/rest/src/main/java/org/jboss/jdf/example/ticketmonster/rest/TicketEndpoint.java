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
import org.jboss.jdf.example.ticketmonster.rest.dto.TicketDTO;
import org.jboss.jdf.example.ticketmonster.model.Ticket;

/**
 * 
 */
@Stateless
@Path("/tickets")
public class TicketEndpoint
{
   @PersistenceContext(unitName="primary")
   private EntityManager em;

   @POST
   @Consumes("application/json")
   public Response create(TicketDTO dto)
   {
      Ticket entity = dto.fromDTO(null, em);
      em.persist(entity);
      return Response.created(UriBuilder.fromResource(TicketEndpoint.class).path(String.valueOf(entity.getId())).build()).build();
   }

   @DELETE
   @Path("/{id:[0-9][0-9]*}")
   public Response deleteById(@PathParam("id") Long id)
   {
      Ticket entity = em.find(Ticket.class, id);
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
      TypedQuery<Ticket> findByIdQuery = em.createQuery("SELECT DISTINCT t FROM Ticket t LEFT JOIN FETCH t.ticketCategory WHERE t.id = :entityId ORDER BY t.id", Ticket.class);
      findByIdQuery.setParameter("entityId", id);
      Ticket entity;
      try {
         entity = findByIdQuery.getSingleResult();
      } catch (NoResultException nre) {
         entity = null;
      }
      if (entity == null) {
        return Response.status(Status.NOT_FOUND).build();
      }
      TicketDTO dto = new TicketDTO(entity);
      return Response.ok(dto).build();
   }

   @GET
   @Produces("application/json")
   public List<TicketDTO> listAll(@QueryParam("start") Integer startPosition, @QueryParam("max") Integer maxResult)
   {
      TypedQuery<Ticket> findAllQuery = em.createQuery("SELECT DISTINCT t FROM Ticket t LEFT JOIN FETCH t.ticketCategory ORDER BY t.id", Ticket.class);
      if (startPosition != null)
      {
         findAllQuery.setFirstResult(startPosition);
      }
      if (maxResult != null)
      {
         findAllQuery.setMaxResults(maxResult);
      }
      final List<Ticket> searchResults = findAllQuery.getResultList();
      final List<TicketDTO> results = new ArrayList<TicketDTO>();
      for(Ticket searchResult: searchResults) {
        TicketDTO dto = new TicketDTO(searchResult);
        results.add(dto);
      }
      return results;
   }

   @PUT
   @Path("/{id:[0-9][0-9]*}")
   @Consumes("application/json")
   public Response update(@PathParam("id") Long id, TicketDTO dto)
   {
      TypedQuery<Ticket> findByIdQuery = em.createQuery("SELECT DISTINCT t FROM Ticket t LEFT JOIN FETCH t.ticketCategory WHERE t.id = :entityId ORDER BY t.id", Ticket.class);
      findByIdQuery.setParameter("entityId", id);
      Ticket entity;
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
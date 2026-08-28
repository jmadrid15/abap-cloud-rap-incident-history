@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Incident Root'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_INCT_615
  as select from zdt_inct_615
  composition [0..*] of ZI_INCT_H_615   as _History
  association [0..1] to ZI_STATUS_615   as _Status   on $projection.Status = _Status.StatusCode
  association [0..1] to ZI_PRIORITY_615 as _Priority on $projection.Priority = _Priority.PriorityCode
{
  key inc_uuid              as IncUuid,
      incident_id           as IncidentId,
      title                 as Title,
      description           as Description,
      status                as Status,
      priority              as Priority,
      creation_date         as CreationDate,
      changed_date          as ChangedDate,
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      _History,
      _Priority,
      _Status
}

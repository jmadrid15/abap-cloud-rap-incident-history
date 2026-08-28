@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Incident History'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_INCT_H_615
  as select from zdt_inct_h_615
  association to parent ZI_INCT_615 as _Incident on $projection.IncUuid = _Incident.IncUuid
{
  key his_uuid              as HisUuid,
      inc_uuid              as IncUuid,
      his_id                as HisId,
      previous_status       as PreviousStatus,
      new_status            as NewStatus,
      text                  as Text,
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
      _Incident
}

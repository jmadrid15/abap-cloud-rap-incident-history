@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View - Incident Root'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_INCT_615
  provider contract transactional_query
  as projection on ZI_INCT_615

{
  key IncUuid,
      IncidentId,
      Title,
      Description,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_STATUS_615', element: 'StatusCode' } }]
      Status,
       @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_PRIORITY_615', element: 'PriorityCode' } }]
      Priority,
      CreationDate,
      ChangedDate,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      _History : redirected to composition child ZC_INCT_H_615,
      _Priority,
      _Status
}

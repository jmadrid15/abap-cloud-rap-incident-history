@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Incident Priority'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_PRIORITY_615 as select from zdt_priority_615
{
    key priority_code as PriorityCode,
    priority_description as PriorityDescription
}

@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Incident Status'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_STATUS_615 as select from zdt_status_615
{
    key status_code as StatusCode,
    status_description as StatusDescription
}

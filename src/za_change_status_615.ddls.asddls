@EndUserText.label: 'Change Status Parameter'
define abstract entity ZA_CHANGE_STATUS_615
{
  @EndUserText.label: 'Change Status'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_STATUS_615', element: 'StatusCode' } }]
  NewStatus   : zde_status_code_615;

  @EndUserText.label: 'Add Observation Text'
  Observation : abap.char(40);
}

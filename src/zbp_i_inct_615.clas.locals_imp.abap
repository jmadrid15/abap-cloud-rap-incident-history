class lcl_incident_buffer definition.
  public section.
    types: begin of ty_observation,
             inc_uuid    type sysuuid_x16,
             observation type string,
           end of ty_observation,
           tt_observation type hashed table of ty_observation with unique key inc_uuid.

    class-data gt_observations type tt_observation.
endclass.

class lhc_Incident definition inheriting from cl_abap_behavior_handler.
  private section.

    constants:
      begin of incident_status,
        open        type c length 2 value 'OP',
        in_progress type c length 2 value 'IP',
        pending     type c length 2 value 'PE',
        completed   type c length 2 value 'CO',
        closed      type c length 2 value 'CL',
        canceled    type c length 2 value 'CN',
      end of incident_status.

    methods get_instance_features for instance features
      keys request requested_features for Incident result result.

    methods get_instance_authorizations for instance authorization
      keys request requested_authorizations for Incident result result.

    methods get_global_authorizations for global authorization
      request requested_authorizations for Incident result result.

    methods changeStatus for modify
       keys for action Incident~changeStatus result result.

    methods setInitialValues for determine on modify
       keys for Incident~setInitialValues.

    methods setInitialHistory for determine on save
       keys for Incident~setInitialHistory.

    methods validateMandatoryFields for validate on save
       keys for Incident~validateMandatoryFields.


    methods setChangedDate for determine on modify
       keys for Incident~setChangedDate.
    methods validateDateRange for validate on save
       keys for Incident~validateDateRange.

endclass.

class lhc_Incident implementation.

  method get_instance_features.

    read entities of zi_inct_615 in local mode
      entity Incident
      fields ( Status )
      with corresponding #( keys )
      result data(lt_incidents).

    result = value #( for incident in lt_incidents (  %tky = incident-%tky
                                                      %action-changeStatus = cond #(
                                                        when incident-Status = incident_status-closed
                                                          or incident-Status = incident_status-canceled
                                                          or incident-Status = incident_status-completed
                                                        then if_abap_behv=>fc-o-disabled
                                                        else if_abap_behv=>fc-o-enabled ) ) ).

  endmethod.

  method get_instance_authorizations.

    read entities of zi_inct_615 in local mode
      entity Incident
      fields ( LocalCreatedBy )
      with corresponding #( keys )
      result data(lt_incidents)
      failed failed.

    check lt_incidents is not initial.

    loop at lt_incidents assigning field-symbol(<incident>).

      " Evaluar si el usuario actual es el creador o el administrador
      data(lv_update_authorized) = cond #(
        when sy-uname = <incident>-LocalCreatedBy or sy-uname = 'CB9980000615'
        then if_abap_behv=>auth-allowed
        else if_abap_behv=>auth-unauthorized
      ).

      " Asignar el resultado al componente %update
      append value #(
        %tky    = <incident>-%tky
        %update = lv_update_authorized
      ) to result.

    endloop.

  endmethod.

  method get_global_authorizations.
  endmethod.

  method changeStatus.

    data lt_status_update type table for update zi_inct_615.

    read entities of zi_inct_615 in local mode
      entity Incident
      fields ( Status LocalCreatedBy )
      with corresponding #( keys )
      result data(lt_incidents).

    loop at lt_incidents assigning field-symbol(<incident>).

      data(lv_new_status)     = keys[ key id %tky = <incident>-%tky ]-%param-NewStatus.
      data(lv_current_status) = <incident>-Status.

      " ----------------------------------------------------------------------
      " VALIDACIÓN 1: Transiciones de Estado Finalizados/Cancelados
      " ----------------------------------------------------------------------
      if    lv_current_status = incident_status-canceled
         or lv_current_status = incident_status-completed
         or lv_current_status = incident_status-closed.

        append value #( %tky = <incident>-%tky ) to failed-incident.
        append value #( %tky = <incident>-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'El incidente se encuentra finalizado o cancelado. No se permite cambiar el estatus.' )
                        %op-%action-changeStatus = if_abap_behv=>mk-on
                      ) to reported-incident.
        continue.
      endif.

      if lv_current_status = incident_status-pending
        and ( lv_new_status = incident_status-completed
            or lv_new_status = incident_status-closed ).

        append value #( %tky = <incident>-%tky ) to failed-incident.
        append value #( %tky = <incident>-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Un incidente en estado Pendiente (PE) no puede pasar directamente a Completado o Cerrado.' )
                        %op-%action-changeStatus = if_abap_behv=>mk-on
                      ) to reported-incident.
        continue.
      endif.

      " ----------------------------------------------------------------------
      " VALIDACIÓN 2: Responsable obligatorio para In Progress (IP)
      " ----------------------------------------------------------------------
      if lv_new_status = incident_status-in_progress and <incident>-LocalCreatedBy is initial.

        append value #( %tky = <incident>-%tky ) to failed-incident.
        append value #( %tky = <incident>-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Para cambiar el estado a In Progress (IP), debe existir un usuario responsable asociado.' )
                        %op-%action-changeStatus = if_abap_behv=>mk-on
                      ) to reported-incident.
        continue.
      endif.

      " ----------------------------------------------------------------------
      " PROCESAMIENTO: Preparar actualización del estado
      " ----------------------------------------------------------------------
      append value #(
          %tky   = <incident>-%tky
          Status = lv_new_status
      ) to lt_status_update.

      data(lv_observation) = keys[ key id %tky = <incident>-%tky ]-%param-observation.


      "" Insertar en el buffer para el metodo save_modified
      insert value #( inc_uuid    = <incident>-IncUuid
                      observation = lv_observation )
        into table lcl_incident_buffer=>gt_observations.


    endloop.

    " Actualizar la entidad principal
    modify entities of zi_inct_615 in local mode
      entity Incident
      update fields ( Status )
      with lt_status_update
      failed data(lt_failed)
      reported data(lt_reported_upd).

    if lt_reported_upd-incident is not initial.
      append lines of lt_reported_upd-incident to reported-incident.
    endif.

    " Lectura final para llenar la estructura 'result' de la UI
    read entities of zi_inct_615 in local mode
       entity Incident
       all fields
       with corresponding #( keys )
       result data(lt_updated_incidents).

    result = value #( for incident in lt_updated_incidents
                      ( %tky   = incident-%tky
                        %param = incident ) ).

  endmethod.

  method setInitialValues.

    read entities of zi_inct_615 in local mode
        entity Incident
        fields ( IncidentId )
        with corresponding #( keys )
        result data(incidents).

    check incidents is not initial.

    select single from zi_inct_615
        fields max( IncidentId )
        into @data(lv_max_incident_id).

    modify entities of zi_inct_615 in local mode
        entity Incident
        update fields ( IncidentId Status CreationDate )
        with value #( for incident in incidents index into i
                            ( %tky = incident-%tky
                              IncidentId = lv_max_incident_id + 1
                              Status     = incident_status-open
                              CreationDate = cl_abap_context_info=>get_system_date( ) ) ).

  endmethod.

  method setInitialHistory.

    read entities of zi_inct_615 in local mode
      entity Incident
      fields ( Status )
      with corresponding #( keys )
      result data(incidents).

    check incidents is not initial.

    modify entities of zi_inct_615 in local mode
      entity Incident
      create by \_History
      fields ( HisId NewStatus Text )
      with value #( for incident in incidents (
        %tky    = incident-%tky
        %target = value #( (
          %cid      = 'CID_INIT_HIST_' && incident-IncUuid
          HisId     = 1
          NewStatus = incident_status-open
          Text      = 'First Incident'
        ) )
      ) )
      failed data(lt_failed)
      reported data(lt_reported).

  endmethod.

  method setChangedDate.

    read entities of zi_inct_615 in local mode
        entity Incident
        fields ( ChangedDate )
        with corresponding #( keys )
        result data(incidents).

    check incidents is not initial.

    data(lv_today) = cl_abap_context_info=>get_system_date( ).

    modify entities of zi_inct_615 in local mode
      entity Incident
      update fields ( ChangedDate )
      with value #( for incident in incidents (
        %tky        = incident-%tky
        ChangedDate = lv_today
      ) ).

  endmethod.

  method validateMandatoryFields.

    " 1. Leer los campos obligatorios de los incidentes afectados
    read entities of zi_inct_615 in local mode
      entity Incident
      fields ( Title Description Priority Status CreationDate )
      with corresponding #( keys )
      result data(lt_incidents).

    " 2. Validar cada registro
    loop at lt_incidents assigning field-symbol(<inc>).

      " Validar TITLE
      if <inc>-Title is initial.
        append value #( %tky = <inc>-%tky ) to failed-incident.
        append value #(
          %tky          = <inc>-%tky
          %element-Title = if_abap_behv=>mk-on
          %msg          = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text     = 'El título es un campo obligatorio.' )
        ) to reported-incident.
      endif.

      " Validar DESCRIPTION
      if <inc>-Description is initial.
        append value #( %tky = <inc>-%tky ) to failed-incident.
        append value #(
          %tky                        = <inc>-%tky
          %element-Description = if_abap_behv=>mk-on
          %msg                        = new_message_with_text(
                                          severity = if_abap_behv_message=>severity-error
                                          text     = 'La descripción es un campo obligatorio.' )
        ) to reported-incident.
      endif.

      " Validar PRIORITY
      if <inc>-Priority is initial.
        append value #( %tky = <inc>-%tky ) to failed-incident.
        append value #(
          %tky             = <inc>-%tky
          %element-Priority = if_abap_behv=>mk-on
          %msg             = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text     = 'La prioridad es un campo obligatorio.' )
        ) to reported-incident.
      endif.

      " Validar STATUS
      if <inc>-Status is initial.
        append value #( %tky = <inc>-%tky ) to failed-incident.
        append value #(
          %tky           = <inc>-%tky
          %element-Status = if_abap_behv=>mk-on
          %msg           = new_message_with_text(
                             severity = if_abap_behv_message=>severity-error
                             text     = 'El estatus es un campo obligatorio.' )
        ) to reported-incident.
      endif.

      " Validar CREATION_DATE
      if <inc>-CreationDate is initial.
        append value #( %tky = <inc>-%tky ) to failed-incident.
        append value #(
          %tky                 = <inc>-%tky
          %element-CreationDate = if_abap_behv=>mk-on
          %msg                 = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text     = 'La fecha de creación es un campo obligatorio.' )
        ) to reported-incident.
      endif.

    endloop.

  endmethod.

  method validateDateRange.

    read entities of zi_inct_615 in local mode
        entity Incident
        fields ( CreationDate ChangedDate )
        with corresponding #( keys )
        result data(lt_incidents).

    " Obtener la fecha actual del sistema en ABAP Cloud
    data(lv_today) = cl_abap_context_info=>get_system_date( ).

    " 2. Evaluar cada registro
    loop at lt_incidents assigning field-symbol(<inc>).

      " ----------------------------------------------------------------------
      " REGLA 1: No se permite registrar un incidente con fecha futura
      " ----------------------------------------------------------------------
      if <inc>-CreationDate > lv_today.

        " Bloquear el guardado de la instancia
        append value #( %tky = <inc>-%tky ) to failed-incident.

        " Reportar el mensaje de error vinculado al campo CreationDate
        append value #(
          %tky                  = <inc>-%tky
          %element-CreationDate = if_abap_behv=>mk-on
          %msg                  = new_message_with_text(
                                    severity = if_abap_behv_message=>severity-error
                                    text     = 'La fecha de creación no puede ser una fecha futura.' )
        ) to reported-incident.

      endif.

      " ----------------------------------------------------------------------
      " REGLA 2: CHANGE_DATE no puede ser anterior a CREATION_DATE
      " ----------------------------------------------------------------------
      if <inc>-ChangedDate is not initial
         and <inc>-ChangedDate < <inc>-CreationDate.

        " Bloquear el guardado de la instancia
        append value #( %tky = <inc>-%tky ) to failed-incident.

        " Reportar el mensaje de error vinculado al campo ChangedDate
        append value #(
          %tky                 = <inc>-%tky
          %element-ChangedDate = if_abap_behv=>mk-on
          %msg                 = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text     = 'La fecha de cambio no puede ser anterior a la fecha de creación.' )
        ) to reported-incident.

      endif.

    endloop.

  endmethod.

endclass.

class lsc_ZI_INCT_615 definition inheriting from cl_abap_behavior_saver.
  protected section.

    methods save_modified redefinition.

    methods cleanup_finalize redefinition.

endclass.

class lsc_ZI_INCT_615 implementation.



  method save_modified.

    check update-incident is not initial.

    select b~inc_uuid, b~status
      from @update-incident as a
      inner join zdt_inct_615 as b on b~inc_uuid = a~IncUuid
      into table @data(lt_old_status).

    data: lt_history type table of zdt_inct_h_615.

    loop at update-incident assigning field-symbol(<inc_updated>).

      data(ls_old) = value #( lt_old_status[ inc_uuid = <inc_updated>-IncUuid ] optional ).

      if ls_old is not initial and ls_old-status <> <inc_updated>-Status.

        " 1. Generar UUID
        try.
            data(lv_his_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
          catch cx_uuid_error.
            clear lv_his_uuid.
        endtry.


        select from zdt_inct_h_615
             fields max( his_id )
             where inc_uuid = @<inc_updated>-IncUuid
           into @data(lv_max_his_id).

        data lv_next_his_id type zdt_inct_h_615-his_id.
        lv_next_his_id = lv_max_his_id + 1.

        " 3. Extraer la observación del buffer
        data(lv_observation) = value #( lcl_incident_buffer=>gt_observations[ inc_uuid = <inc_updated>-IncUuid ]-observation optional ).

        append value #(
          his_uuid              = lv_his_uuid
          inc_uuid              = <inc_updated>-IncUuid
          his_id                = lv_next_his_id
          previous_status       = ls_old-status
          new_status            = <inc_updated>-Status
          text                  = lv_observation
          local_last_changed_by = sy-uname
          last_changed_at       = cl_abap_context_info=>get_system_date( )
        ) to lt_history.

      endif.
    endloop.

    if lt_history is not initial.
      insert zdt_inct_h_615 from table @lt_history.
    endif.

    clear lcl_incident_buffer=>gt_observations.

  endmethod.

  method cleanup_finalize.
  endmethod.

endclass.




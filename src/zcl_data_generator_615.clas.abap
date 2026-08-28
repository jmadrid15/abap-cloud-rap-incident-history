class zcl_data_generator_615 definition
  public
  final
  create public .

  public section.

    interfaces if_oo_adt_classrun .
  protected section.
  private section.
endclass.



class zcl_data_generator_615 implementation.

  method if_oo_adt_classrun~main.

    delete from zdt_status_615.

    insert zdt_status_615 from table @( value #(
      ( status_code = 'OP' status_description = 'Open' )
      ( status_code = 'IP' status_description = 'In Progress' )
      ( status_code = 'PE' status_description = 'Pending' )
      ( status_code = 'CO' status_description = 'Completed' )
      ( status_code = 'CL' status_description = 'Closed' )
      ( status_code = 'CN' status_description = 'Canceled' )
    ) ).

    delete from zdt_priority_615.

    insert zdt_priority_615 from table @( value #(
      ( priority_code = 'H' priority_description = 'High' )
      ( priority_code = 'M' priority_description = 'Medium' )
      ( priority_code = 'L' priority_description = 'Low' )
    ) ).

    try.

        data(lv_uuid_1) = cl_system_uuid=>create_uuid_x16_static( ).
        data(lv_uuid_2) = cl_system_uuid=>create_uuid_x16_static( ).
        data(lv_uuid_3) = cl_system_uuid=>create_uuid_x16_static( ).
        data(lv_uuid_4) = cl_system_uuid=>create_uuid_x16_static( ).
        data(lv_uuid_5) = cl_system_uuid=>create_uuid_x16_static( ).

        data(lv_user)      = sy-uname.
        data(lv_date)      = cl_abap_context_info=>get_system_date( ).
        get time stamp field data(lv_timestamp).

        delete from zdt_inct_615.


        insert zdt_inct_615 from table @( value #(
          ( inc_uuid              = lv_uuid_1
            incident_id           = '00000001'
            title                 = 'Error en login'
            description           = 'Usuario no puede acceder con sus credenciales'
            status                = 'OP'
            priority              = 'H'
            creation_date         = lv_date
            changed_date          = lv_date
            local_created_by      = lv_user
            local_created_at      = lv_timestamp
            local_last_changed_by = lv_user
            local_last_changed_at = lv_timestamp
            last_changed_at       = lv_timestamp )

          ( inc_uuid              = lv_uuid_2
            incident_id           = '00000002'
            title                 = 'Falla en impresora'
            description           = 'Impresora del piso 2 fuera de servicio'
            status                = 'IP'
            priority              = 'M'
            creation_date         = lv_date
            changed_date          = lv_date
            local_created_by      = lv_user
            local_created_at      = lv_timestamp
            local_last_changed_by = lv_user
            local_last_changed_at = lv_timestamp
            last_changed_at       = lv_timestamp )

          ( inc_uuid              = lv_uuid_3
            incident_id           = '00000003'
            title                 = 'Solicitud de monitor'
            description           = 'Se requiere segundo monitor para desarrollo'
            status                = 'PE'
            priority              = 'L'
            creation_date         = lv_date
            changed_date          = lv_date
            local_created_by      = lv_user
            local_created_at      = lv_timestamp
            local_last_changed_by = lv_user
            local_last_changed_at = lv_timestamp
            last_changed_at       = lv_timestamp )

          ( inc_uuid              = lv_uuid_4
            incident_id           = '00000004'
            title                 = 'Caida de servidor'
            description           = 'Servidor de desarrollo no responde'
            status                = 'CO'
            priority              = 'V'
            creation_date         = lv_date
            changed_date          = lv_date
            local_created_by      = lv_user
            local_created_at      = lv_timestamp
            local_last_changed_by = lv_user
            local_last_changed_at = lv_timestamp
            last_changed_at       = lv_timestamp )

          ( inc_uuid              = lv_uuid_5
            incident_id           = '00000005'
            title                 = 'Lentitud en red'
            description           = 'Conexion lenta al descargar archivos pesados'
            status                = 'CL'
            priority              = 'M'
            creation_date         = lv_date
            changed_date          = lv_date
            local_created_by      = lv_user
            local_created_at      = lv_timestamp
            local_last_changed_by = lv_user
            local_last_changed_at = lv_timestamp
            last_changed_at       = lv_timestamp )
        ) ).

        delete from zdt_inct_h_615.

        insert zdt_inct_h_615 from table @( value #(
          ( his_uuid              = cl_system_uuid=>create_uuid_x16_static( )
            inc_uuid              = lv_uuid_1
            his_id                = '00000001'
            previous_status       = ''
            new_status            = 'OP'
            text                  = 'Incidente creado por el usuario'
            local_created_by      = lv_user
            local_created_at      = lv_timestamp
            local_last_changed_by = lv_user
            local_last_changed_at = lv_timestamp
            last_changed_at       = lv_timestamp )

          ( his_uuid              = cl_system_uuid=>create_uuid_x16_static( )
            inc_uuid              = lv_uuid_2
            his_id                = '00000001'
            previous_status       = 'OP'
            new_status            = 'IP'
            text                  = 'Asignado a soporte tecnico'
            local_created_by      = lv_user
            local_created_at      = lv_timestamp
            local_last_changed_by = lv_user
            local_last_changed_at = lv_timestamp
            last_changed_at       = lv_timestamp )

          ( his_uuid              = cl_system_uuid=>create_uuid_x16_static( )
            inc_uuid              = lv_uuid_3
            his_id                = '00000001'
            previous_status       = 'OP'
            new_status            = 'PE'
            text                  = 'A la espera de aprobacion de compras'
            local_created_by      = lv_user
            local_created_at      = lv_timestamp
            local_last_changed_by = lv_user
            local_last_changed_at = lv_timestamp
            last_changed_at       = lv_timestamp )

          ( his_uuid              = cl_system_uuid=>create_uuid_x16_static( )
            inc_uuid              = lv_uuid_4
            his_id                = '00000001'
            previous_status       = 'IP'
            new_status            = 'CO'
            text                  = 'Servidor reiniciado con exito'
            local_created_by      = lv_user
            local_created_at      = lv_timestamp
            local_last_changed_by = lv_user
            local_last_changed_at = lv_timestamp
            last_changed_at       = lv_timestamp )

          ( his_uuid              = cl_system_uuid=>create_uuid_x16_static( )
            inc_uuid              = lv_uuid_5
            his_id                = '00000001'
            previous_status       = 'CO'
            new_status            = 'CL'
            text                  = 'Incidente cerrado por el usuario'
            local_created_by      = lv_user
            local_created_at      = lv_timestamp
            local_last_changed_by = lv_user
            local_last_changed_at = lv_timestamp
            last_changed_at       = lv_timestamp )
        ) ).

      catch cx_uuid_error.
        " Manejo de excepcion al generar UUIDs
    endtry.




  endmethod.

endclass.




























































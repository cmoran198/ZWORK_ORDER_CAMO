CLASS zcl_work_order_inicio_camo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_work_order_inicio_camo IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    " ============================================================
    " CUSTOMER
    " ============================================================

    SELECT SINGLE customer_id
      FROM ztcustomer_camo
      WHERE customer_id = '00000001'
      INTO @DATA(lv_customer_id).

    IF sy-subrc <> 0.

      DATA(ls_customer) = VALUE ztcustomer_camo(
        customer_id = '00000001'
        name        = 'Customer Test CAMO'
        address     = 'Tegucigalpa'
        phone       = '99999999'
      ).

      INSERT ztcustomer_camo FROM @ls_customer.

      IF sy-subrc = 0.
        out->write( 'Customer 00000001 created successfully.' ).
      ELSE.
        out->write( 'Error creating customer.' ).
      ENDIF.

    ELSE.

      out->write( 'Customer 00000001 already exists.' ).

    ENDIF.


    " ============================================================
    " TECHNICIAN
    " ============================================================

    SELECT SINGLE technician_id
      FROM zttech_camo
      WHERE technician_id = 'TEC00001'
      INTO @DATA(lv_technician_id).

    IF sy-subrc <> 0.

      DATA(ls_technician) = VALUE zttech_camo(
        technician_id = 'TEC00001'
        name          = 'Technician Test CAMO'
        specialty     = 'Maintenance'
      ).

      INSERT zttech_camo FROM @ls_technician.

      IF sy-subrc = 0.
        out->write( 'Technician TEC00001 created successfully.' ).
      ELSE.
        out->write( 'Error creating technician.' ).
      ENDIF.

    ELSE.

      out->write( 'Technician TEC00001 already exists.' ).

    ENDIF.

  ENDMETHOD.

ENDCLASS.

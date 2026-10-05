CLASS zcl_work_order_valid_test_camo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_work_order_valid_test_camo IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    out->write( '========================================' ).
    out->write( 'VALIDATION TEST - CAMO' ).
    out->write( '========================================' ).


    " ============================================================
    " 1. CREATE - DATOS VALIDOS
    " ============================================================

    DATA(lv_valid_create) =
      zcl_work_order_valid_camo=>validate_create_order(
        iv_customer_id   = '00000001'
        iv_technician_id = 'TEC00001'
        iv_priority      = 'A'
      ).

    IF lv_valid_create = abap_true.
      out->write( 'CREATE VALID DATA: OK' ).
    ELSE.
      out->write( 'CREATE VALID DATA: FAILED' ).
    ENDIF.


    " ============================================================
    " 2. CREATE - CLIENTE INEXISTENTE
    " ============================================================

    DATA(lv_invalid_customer) =
      zcl_work_order_valid_camo=>validate_create_order(
        iv_customer_id   = '99999999'
        iv_technician_id = 'TEC00001'
        iv_priority      = 'A'
      ).

    IF lv_invalid_customer = abap_false.
      out->write( 'INVALID CUSTOMER: OK - REJECTED' ).
    ELSE.
      out->write( 'INVALID CUSTOMER: FAILED' ).
    ENDIF.


    " ============================================================
    " 3. CREATE - TECNICO INEXISTENTE
    " ============================================================

    DATA(lv_invalid_technician) =
      zcl_work_order_valid_camo=>validate_create_order(
        iv_customer_id   = '00000001'
        iv_technician_id = 'TEC99999'
        iv_priority      = 'A'
      ).

    IF lv_invalid_technician = abap_false.
      out->write( 'INVALID TECHNICIAN: OK - REJECTED' ).
    ELSE.
      out->write( 'INVALID TECHNICIAN: FAILED' ).
    ENDIF.


    " ============================================================
    " 4. CREATE - PRIORIDAD INVALIDA
    " ============================================================

    DATA(lv_invalid_priority) =
      zcl_work_order_valid_camo=>validate_create_order(
        iv_customer_id   = '00000001'
        iv_technician_id = 'TEC00001'
        iv_priority      = 'X'
      ).

    IF lv_invalid_priority = abap_false.
      out->write( 'INVALID PRIORITY: OK - REJECTED' ).
    ELSE.
      out->write( 'INVALID PRIORITY: FAILED' ).
    ENDIF.


    " ============================================================
    " 5. STATUS Y PRIORITY VALIDOS
    " ============================================================

    DATA(lv_status_priority) =
      zcl_work_order_valid_camo=>validate_status_and_priority(
        iv_status   = 'PE'
        iv_priority = 'A'
      ).

    IF lv_status_priority = abap_true.
      out->write( 'STATUS PE / PRIORITY A: OK' ).
    ELSE.
      out->write( 'STATUS PE / PRIORITY A: FAILED' ).
    ENDIF.


    " ============================================================
    " 6. STATUS INVALIDO
    " ============================================================

    DATA(lv_invalid_status) =
      zcl_work_order_valid_camo=>validate_status_and_priority(
        iv_status   = 'XX'
        iv_priority = 'A'
      ).

    IF lv_invalid_status = abap_false.
      out->write( 'INVALID STATUS: OK - REJECTED' ).
    ELSE.
      out->write( 'INVALID STATUS: FAILED' ).
    ENDIF.


    " ============================================================
    " 7. ORDEN COMPLETADA NO EDITABLE
    " ============================================================

    DATA(lv_update_completed) =
      zcl_work_order_valid_camo=>validate_update_order(
        iv_work_order_id = '0000000001'
        iv_status        = 'CO'
      ).

    IF lv_update_completed = abap_false.
      out->write( 'UPDATE COMPLETED ORDER: OK - REJECTED' ).
    ELSE.
      out->write( 'UPDATE COMPLETED ORDER: FAILED' ).
    ENDIF.


    " ============================================================
    " 8. ORDEN COMPLETADA NO ELIMINABLE
    " ============================================================

    DATA(lv_delete_completed) =
      zcl_work_order_valid_camo=>validate_delete_order(
        iv_work_order_id = '0000000001'
        iv_status        = 'CO'
      ).

    IF lv_delete_completed = abap_false.
      out->write( 'DELETE COMPLETED ORDER: OK - REJECTED' ).
    ELSE.
      out->write( 'DELETE COMPLETED ORDER: FAILED' ).
    ENDIF.


    out->write( '========================================' ).
    out->write( 'END VALIDATION TEST' ).
    out->write( '========================================' ).

  ENDMETHOD.

ENDCLASS.

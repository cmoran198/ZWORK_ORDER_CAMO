CLASS zcl_work_order_crud_test_camo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.

    CLASS-METHODS reset_test_data.

    CLASS-METHODS test_read_work_orders
      RETURNING
        VALUE(rt_work_orders)
          TYPE zcl_work_order_crud_camo=>tt_work_orders.

    CLASS-METHODS test_create_work_order
      RETURNING
        VALUE(rv_success) TYPE abap_bool.

    CLASS-METHODS test_read_work_order
      RETURNING
        VALUE(rs_work_order) TYPE ztworkorder_camo.

    CLASS-METHODS test_update_work_order
      RETURNING
        VALUE(rv_success) TYPE abap_bool.

    CLASS-METHODS test_delete_work_order
      RETURNING
        VALUE(rv_success) TYPE abap_bool.

ENDCLASS.


CLASS zcl_work_order_crud_test_camo IMPLEMENTATION.



  METHOD if_oo_adt_classrun~main.

    out->write( '========================================' ).
    out->write( 'WORK ORDER CRUD TEST - CAMO' ).
    out->write( '========================================' ).

    " Limpiar solamente los IDs reservados para esta prueba
    reset_test_data( ).

    " ============================================================
    " CREATE
    " ============================================================

    DATA(lv_create) = test_create_work_order( ).

    IF lv_create = abap_true.
      out->write( 'CREATE: OK' ).
    ELSE.
      out->write( 'CREATE: FAILED' ).
    ENDIF.


    " ============================================================
    " READ
    " ============================================================

    DATA(ls_work_order) = test_read_work_order( ).

    IF ls_work_order-work_order_id IS INITIAL.

      out->write( 'READ: FAILED' ).

    ELSE.

      out->write( 'READ: OK' ).

      out->write(
        |Work Order: { ls_work_order-work_order_id }| ).

      out->write(
        |Customer: { ls_work_order-customer_id }| ).

      out->write(
        |Technician: { ls_work_order-technician_id }| ).

      out->write(
        |Status: { ls_work_order-status }| ).

      out->write(
        |Priority: { ls_work_order-priority }| ).

    ENDIF.


    " ============================================================
    " UPDATE
    " ============================================================

    DATA(lv_update) = test_update_work_order( ).

    IF lv_update = abap_true.

      out->write( 'UPDATE: OK' ).

      DATA(ls_updated_order) =
        zcl_work_order_crud_camo=>read_work_order(
          iv_work_order_id = '0000000001'
        ).

      out->write(
        |New Status: { ls_updated_order-status }| ).

      out->write(
        |New Priority: { ls_updated_order-priority }| ).

      out->write(
        |Description: { ls_updated_order-description }| ).



    ELSE.

      out->write( 'UPDATE: FAILED' ).

    ENDIF.

    " ============================================================
    " FILTERED READ
    " ============================================================

    DATA(lt_filtered_orders) =
      test_read_work_orders( ).

    IF line_exists(
         lt_filtered_orders[
           work_order_id = '0000000001'
         ]
       ).

      out->write( 'FILTERED READ: OK' ).

      out->write(
        |Rows found: { lines( lt_filtered_orders ) }|
      ).

      LOOP AT lt_filtered_orders INTO DATA(ls_filtered).

        out->write(
          |Order: { ls_filtered-work_order_id } | &&
          |Customer: { ls_filtered-customer_id } | &&
          |Status: { ls_filtered-status } | &&
          |Date: { ls_filtered-creation_date }|
        ).

      ENDLOOP.

    ELSE.

      out->write( 'FILTERED READ: FAILED' ).

    ENDIF.




    " ============================================================
    " DELETE
    " ============================================================

    DATA(lv_delete) = test_delete_work_order( ).

    IF lv_delete = abap_true.
      out->write( 'DELETE: OK' ).
    ELSE.
      out->write( 'DELETE: FAILED' ).
    ENDIF.


    out->write( '========================================' ).
    out->write( 'END CRUD TEST' ).
    out->write( '========================================' ).

  ENDMETHOD.

  METHOD test_read_work_orders.

    DATA(lv_today) =
      cl_abap_context_info=>get_system_date( ).

    rt_work_orders =
      zcl_work_order_crud_camo=>read_work_orders(
        iv_customer_id = '00000001'
        iv_status      = 'CO'
        iv_date_from   = lv_today
        iv_date_to     = lv_today
      ).

  ENDMETHOD.

  METHOD reset_test_data.

    " Eliminar historial de los IDs utilizados por la prueba
    DELETE FROM ztwohist_camo
      WHERE work_order_id = '0000000001'
         OR work_order_id = '0000000002'.

    " Eliminar órdenes anteriores de prueba
    DELETE FROM ztworkorder_camo
      WHERE work_order_id = '0000000001'
         OR work_order_id = '0000000002'.

  ENDMETHOD.


  METHOD test_create_work_order.

    DATA(ls_work_order) = VALUE ztworkorder_camo(

      work_order_id = '0000000001'
      customer_id   = '00000001'
      technician_id = 'TEC00001'

      creation_date =
        cl_abap_context_info=>get_system_date( )

      status      = 'PE'
      priority    = 'A'
      description = 'Initial test work order'

    ).

    rv_success =
      zcl_work_order_crud_camo=>create_work_order(
        is_work_order = ls_work_order
      ).

  ENDMETHOD.


  METHOD test_read_work_order.

    rs_work_order =
      zcl_work_order_crud_camo=>read_work_order(
        iv_work_order_id = '0000000001'
      ).

  ENDMETHOD.


  METHOD test_update_work_order.

    rv_success =
      zcl_work_order_crud_camo=>update_work_order(

        iv_work_order_id = '0000000001'
        iv_status        = 'CO'
        iv_priority      = 'B'
        iv_description   = 'Updated test work order'

      ).

  ENDMETHOD.


  METHOD test_delete_work_order.

    " Utilizamos otra orden porque 0000000001 ya tendrá historial
    DATA(ls_delete_order) = VALUE ztworkorder_camo(

      work_order_id = '0000000002'
      customer_id   = '00000001'
      technician_id = 'TEC00001'

      creation_date =
        cl_abap_context_info=>get_system_date( )

      status      = 'PE'
      priority    = 'B'
      description = 'Order for delete test'

    ).

    DATA(lv_created) =
      zcl_work_order_crud_camo=>create_work_order(
        is_work_order = ls_delete_order
      ).

    IF lv_created = abap_false.
      rv_success = abap_false.
      RETURN.
    ENDIF.

    rv_success =
      zcl_work_order_crud_camo=>delete_work_order(
        iv_work_order_id = '0000000002'
      ).

  ENDMETHOD.

ENDCLASS.

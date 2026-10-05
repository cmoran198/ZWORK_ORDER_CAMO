CLASS zcl_work_order_lock_test_camo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_work_order_lock_test_camo IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA lv_client        TYPE ztworkorder_camo-client.
    DATA lv_work_order_id TYPE ze_wo_id_camo.
    DATA lo_lock          TYPE REF TO if_abap_lock_object.

    lv_client        = sy-mandt.
    lv_work_order_id = '0000000001'.

    out->write( '========================================' ).
    out->write( 'LOCK TEST - CAMO' ).
    out->write( '========================================' ).

    out->write(
      |Work Order: { lv_work_order_id }|
    ).

    TRY.

        " Obtener instancia del objeto de bloqueo
        lo_lock =
          cl_abap_lock_object_factory=>get_instance(
            iv_name = 'EZWORKCAMO'
          ).

        " Intentar bloquear la orden
        lo_lock->enqueue(
          it_parameter = VALUE #(
            ( name  = 'CLIENT'
              value = REF #( lv_client ) )

            ( name  = 'WORK_ORDER_ID'
              value = REF #( lv_work_order_id ) )
          )
        ).

        out->write( 'LOCK: SUCCESS' ).
        out->write( 'Work order locked successfully.' ).

      CATCH cx_abap_foreign_lock.

        out->write( 'LOCK: FAILED' ).
        out->write( 'Work order is already locked.' ).
        RETURN.

      CATCH cx_abap_lock_failure.

        out->write( 'LOCK: TECHNICAL ERROR' ).
        RETURN.

    ENDTRY.


    " ============================================================
    " Liberar bloqueo
    " ============================================================

    TRY.

        lo_lock->dequeue( ).

        out->write( 'UNLOCK: SUCCESS' ).
        out->write( 'Work order unlocked successfully.' ).

      CATCH cx_abap_lock_failure.

        out->write( 'UNLOCK: FAILED' ).

    ENDTRY.


    out->write( '========================================' ).
    out->write( 'END LOCK TEST' ).
    out->write( '========================================' ).

  ENDMETHOD.

ENDCLASS.

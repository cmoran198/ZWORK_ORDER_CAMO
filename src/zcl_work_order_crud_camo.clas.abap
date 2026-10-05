CLASS zcl_work_order_crud_camo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES tt_work_orders
    TYPE STANDARD TABLE OF ztworkorder_camo
    WITH EMPTY KEY.

    CLASS-METHODS read_work_orders
      IMPORTING
        iv_customer_id        TYPE ze_customer_id_camo OPTIONAL
        iv_status             TYPE ze_wo_status_camo OPTIONAL
        iv_date_from          TYPE ztworkorder_camo-creation_date OPTIONAL
        iv_date_to            TYPE ztworkorder_camo-creation_date OPTIONAL
      RETURNING
        VALUE(rt_work_orders) TYPE tt_work_orders.

    CLASS-METHODS create_work_order
      IMPORTING
        is_work_order     TYPE ztworkorder_camo
      RETURNING
        VALUE(rv_success) TYPE abap_bool.

    CLASS-METHODS read_work_order
      IMPORTING
        iv_work_order_id     TYPE ze_wo_id_camo
      RETURNING
        VALUE(rs_work_order) TYPE ztworkorder_camo.

    CLASS-METHODS update_work_order
      IMPORTING
        iv_work_order_id  TYPE ze_wo_id_camo
        iv_status         TYPE ze_wo_status_camo
        iv_priority       TYPE ze_wo_priority_camo
        iv_description    TYPE ztworkorder_camo-description
      RETURNING
        VALUE(rv_success) TYPE abap_bool.

    CLASS-METHODS delete_work_order
      IMPORTING
        iv_work_order_id  TYPE ze_wo_id_camo
      RETURNING
        VALUE(rv_success) TYPE abap_bool.

  PRIVATE SECTION.

    CLASS-METHODS add_history
      IMPORTING
        iv_work_order_id TYPE ze_wo_id_camo.

ENDCLASS.


CLASS zcl_work_order_crud_camo IMPLEMENTATION.

  METHOD create_work_order.

    rv_success = abap_false.

    " El ID de la orden es obligatorio
    IF is_work_order-work_order_id IS INITIAL.
      RETURN.
    ENDIF.

    " Validar cliente, técnico y prioridad
    IF zcl_work_order_valid_camo=>validate_create_order(
         iv_customer_id   = is_work_order-customer_id
         iv_technician_id = is_work_order-technician_id
         iv_priority      = is_work_order-priority ) = abap_false.
      RETURN.
    ENDIF.

    " Validar estado y prioridad
    IF zcl_work_order_valid_camo=>validate_status_and_priority(
         iv_status   = is_work_order-status
         iv_priority = is_work_order-priority ) = abap_false.
      RETURN.
    ENDIF.

    " Verificar que la orden no exista
    SELECT SINGLE work_order_id
      FROM ztworkorder_camo
      WHERE work_order_id = @is_work_order-work_order_id
      INTO @DATA(lv_existing_id).

    IF sy-subrc = 0.
      RETURN.
    ENDIF.

    " Crear orden
    INSERT ztworkorder_camo FROM @is_work_order.

    IF sy-subrc = 0.
      rv_success = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD read_work_order.

    CLEAR rs_work_order.

    SELECT SINGLE *
      FROM ztworkorder_camo
      WHERE work_order_id = @iv_work_order_id
      INTO @rs_work_order.

  ENDMETHOD.


  METHOD update_work_order.

    rv_success = abap_false.

    " ============================================================
    " 1. Leer la orden actual
    " ============================================================

    DATA(ls_work_order) = read_work_order(
      iv_work_order_id = iv_work_order_id
    ).

    IF ls_work_order-work_order_id IS INITIAL.
      RETURN.
    ENDIF.


    " ============================================================
    " 2. Validar que la orden actual se pueda modificar
    " ============================================================

    IF zcl_work_order_valid_camo=>validate_update_order(
         iv_work_order_id = iv_work_order_id
         iv_status        = ls_work_order-status
       ) = abap_false.

      RETURN.

    ENDIF.


    " ============================================================
    " 3. Validar los nuevos valores
    " ============================================================

    IF zcl_work_order_valid_camo=>validate_status_and_priority(
         iv_status   = iv_status
         iv_priority = iv_priority
       ) = abap_false.

      RETURN.

    ENDIF.


    " ============================================================
    " 4. Preparar objeto de bloqueo
    " ============================================================

    DATA lv_client             TYPE ztworkorder_camo-client.
    DATA lv_lock_work_order_id TYPE ze_wo_id_camo.

    DATA lo_lock TYPE REF TO if_abap_lock_object.

    lv_client             = sy-mandt.
    lv_lock_work_order_id = iv_work_order_id.


    " ============================================================
    " 5. Bloquear la orden
    " ============================================================

    TRY.

        lo_lock =
          cl_abap_lock_object_factory=>get_instance(
            iv_name = 'EZWORKCAMO'
          ).

        lo_lock->enqueue(
          it_parameter = VALUE #(
            ( name  = 'CLIENT'
              value = REF #( lv_client ) )

            ( name  = 'WORK_ORDER_ID'
              value = REF #( lv_lock_work_order_id ) )
          )
        ).

      CATCH cx_abap_foreign_lock.
        " Otro usuario/proceso tiene bloqueada la orden
        RETURN.

      CATCH cx_abap_lock_failure.
        " Error técnico al solicitar el bloqueo
        RETURN.

    ENDTRY.


    " ============================================================
    " 6. Actualizar la orden protegida por el lock
    " ============================================================

    UPDATE ztworkorder_camo
      SET status      = @iv_status,
          priority    = @iv_priority,
          description = @iv_description
      WHERE work_order_id = @iv_work_order_id.

    IF sy-subrc = 0.

      " Registrar modificación en historial
      add_history(
        iv_work_order_id = iv_work_order_id
      ).

      rv_success = abap_true.

    ENDIF.


    " ============================================================
    " 7. Liberar el bloqueo
    " ============================================================

    TRY.

        lo_lock->dequeue( ).

      CATCH cx_abap_lock_failure.

        " Si no se puede liberar correctamente,
        " reportamos la operación como fallida
        rv_success = abap_false.

    ENDTRY.

  ENDMETHOD.

  METHOD read_work_orders.

    DATA lr_customer TYPE RANGE OF ze_customer_id_camo.
    DATA lr_status   TYPE RANGE OF ze_wo_status_camo.
    DATA lr_date     TYPE RANGE OF ztworkorder_camo-creation_date.


    " ============================================================
    " FILTRO POR CLIENTE
    " ============================================================

    IF iv_customer_id IS NOT INITIAL.

      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_customer_id
      ) TO lr_customer.

    ENDIF.


    " ============================================================
    " FILTRO POR ESTADO
    " ============================================================

    IF iv_status IS NOT INITIAL.

      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = iv_status
      ) TO lr_status.

    ENDIF.


    " ============================================================
    " FILTRO POR FECHA
    " ============================================================

    IF iv_date_from IS NOT INITIAL
       AND iv_date_to IS NOT INITIAL.

      APPEND VALUE #(
        sign   = 'I'
        option = 'BT'
        low    = iv_date_from
        high   = iv_date_to
      ) TO lr_date.

    ELSEIF iv_date_from IS NOT INITIAL.

      APPEND VALUE #(
        sign   = 'I'
        option = 'GE'
        low    = iv_date_from
      ) TO lr_date.

    ELSEIF iv_date_to IS NOT INITIAL.

      APPEND VALUE #(
        sign   = 'I'
        option = 'LE'
        low    = iv_date_to
      ) TO lr_date.

    ENDIF.


    " ============================================================
    " CONSULTA
    " ============================================================

    SELECT *
      FROM ztworkorder_camo
      WHERE customer_id  IN @lr_customer
        AND status       IN @lr_status
        AND creation_date IN @lr_date
      ORDER BY creation_date, work_order_id
      INTO TABLE @rt_work_orders.

  ENDMETHOD.


  METHOD delete_work_order.

    rv_success = abap_false.

    DATA(ls_work_order) = read_work_order(
      iv_work_order_id = iv_work_order_id ).

    IF ls_work_order-work_order_id IS INITIAL.
      RETURN.
    ENDIF.

    IF zcl_work_order_valid_camo=>validate_delete_order(
         iv_work_order_id = iv_work_order_id
         iv_status        = ls_work_order-status ) = abap_false.
      RETURN.
    ENDIF.

    DELETE FROM ztworkorder_camo
      WHERE work_order_id = @iv_work_order_id.

    IF sy-subrc = 0.
      rv_success = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD add_history.

    DATA lv_max_history_id  TYPE ztwohist_camo-history_id.
    DATA lv_next_history_id TYPE ztwohist_camo-history_id.

    SELECT MAX( history_id )
      FROM ztwohist_camo
      WHERE history_id IS NOT INITIAL
      INTO @lv_max_history_id.

    IF lv_max_history_id IS INITIAL.

      lv_next_history_id = '000000000001'.

    ELSE.

      DATA(lv_next_number) =
        CONV int8( lv_max_history_id ) + 1.

      lv_next_history_id = lv_next_number.

    ENDIF.

    DATA(ls_history) = VALUE ztwohist_camo(
      history_id         = lv_next_history_id
      work_order_id      = iv_work_order_id
      modification_date  = cl_abap_context_info=>get_system_date( )
      change_description = 'Work order updated' ).
    INSERT ztwohist_camo FROM @ls_history.

  ENDMETHOD.

ENDCLASS.

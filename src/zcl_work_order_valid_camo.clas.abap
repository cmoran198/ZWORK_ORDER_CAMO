CLASS zcl_work_order_valid_camo DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.

    CLASS-METHODS validate_create_order
      IMPORTING
        iv_customer_id   TYPE ze_customer_id_camo
        iv_technician_id TYPE ze_tech_id_camo
        iv_priority      TYPE ze_wo_priority_camo
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

    CLASS-METHODS validate_update_order
      IMPORTING
        iv_work_order_id TYPE ze_wo_id_camo
        iv_status        TYPE ze_wo_status_camo
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

    CLASS-METHODS validate_delete_order
      IMPORTING
        iv_work_order_id TYPE ze_wo_id_camo
        iv_status        TYPE ze_wo_status_camo
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

    CLASS-METHODS validate_status_and_priority
      IMPORTING
        iv_status   TYPE ze_wo_status_camo
        iv_priority TYPE ze_wo_priority_camo
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

  PRIVATE SECTION.

    CONSTANTS c_status_pending   TYPE ze_wo_status_camo
      VALUE 'PE'.

    CONSTANTS c_status_completed TYPE ze_wo_status_camo
      VALUE 'CO'.

    CONSTANTS c_priority_high    TYPE ze_wo_priority_camo
      VALUE 'A'.

    CONSTANTS c_priority_low     TYPE ze_wo_priority_camo
      VALUE 'B'.

    CLASS-METHODS check_customer_exists
      IMPORTING
        iv_customer_id TYPE ze_customer_id_camo
      RETURNING
        VALUE(rv_exists) TYPE abap_bool.

    CLASS-METHODS check_technician_exists
      IMPORTING
        iv_technician_id TYPE ze_tech_id_camo
      RETURNING
        VALUE(rv_exists) TYPE abap_bool.

    CLASS-METHODS check_order_exists
      IMPORTING
        iv_work_order_id TYPE ze_wo_id_camo
      RETURNING
        VALUE(rv_exists) TYPE abap_bool.

    CLASS-METHODS check_order_history
      IMPORTING
        iv_work_order_id TYPE ze_wo_id_camo
      RETURNING
        VALUE(rv_exists) TYPE abap_bool.

ENDCLASS.


CLASS zcl_work_order_valid_camo IMPLEMENTATION.

  METHOD validate_create_order.

    rv_valid = abap_false.

    IF iv_customer_id IS INITIAL
       OR iv_technician_id IS INITIAL.
      RETURN.
    ENDIF.

    IF check_customer_exists(
         iv_customer_id = iv_customer_id ) = abap_false.
      RETURN.
    ENDIF.

    IF check_technician_exists(
         iv_technician_id = iv_technician_id ) = abap_false.
      RETURN.
    ENDIF.

    IF iv_priority <> c_priority_high
       AND iv_priority <> c_priority_low.
      RETURN.
    ENDIF.

    rv_valid = abap_true.

  ENDMETHOD.


  METHOD validate_update_order.

    rv_valid = abap_false.

    IF check_order_exists(
         iv_work_order_id = iv_work_order_id ) = abap_false.
      RETURN.
    ENDIF.

    IF iv_status <> c_status_pending.
      RETURN.
    ENDIF.

    rv_valid = abap_true.

  ENDMETHOD.


  METHOD validate_delete_order.

    rv_valid = abap_false.

    IF check_order_exists(
         iv_work_order_id = iv_work_order_id ) = abap_false.
      RETURN.
    ENDIF.

    IF iv_status <> c_status_pending.
      RETURN.
    ENDIF.

    IF check_order_history(
         iv_work_order_id = iv_work_order_id ) = abap_true.
      RETURN.
    ENDIF.

    rv_valid = abap_true.

  ENDMETHOD.


  METHOD validate_status_and_priority.

    rv_valid = abap_false.

    IF iv_status <> c_status_pending
       AND iv_status <> c_status_completed.
      RETURN.
    ENDIF.

    IF iv_priority <> c_priority_high
       AND iv_priority <> c_priority_low.
      RETURN.
    ENDIF.

    rv_valid = abap_true.

  ENDMETHOD.


  METHOD check_customer_exists.

    rv_exists = abap_false.

    SELECT SINGLE customer_id
      FROM ztcustomer_camo
      WHERE customer_id = @iv_customer_id
      INTO @DATA(lv_customer_id).

    IF sy-subrc = 0.
      rv_exists = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD check_technician_exists.

    rv_exists = abap_false.

    SELECT SINGLE technician_id
      FROM zttech_camo
      WHERE technician_id = @iv_technician_id
      INTO @DATA(lv_technician_id).

    IF sy-subrc = 0.
      rv_exists = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD check_order_exists.

    rv_exists = abap_false.

    SELECT SINGLE work_order_id
      FROM ztworkorder_camo
      WHERE work_order_id = @iv_work_order_id
      INTO @DATA(lv_work_order_id).

    IF sy-subrc = 0.
      rv_exists = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD check_order_history.

    rv_exists = abap_false.

    SELECT SINGLE history_id
      FROM ztwohist_camo
      WHERE work_order_id = @iv_work_order_id
      INTO @DATA(lv_history_id).

    IF sy-subrc = 0.
      rv_exists = abap_true.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

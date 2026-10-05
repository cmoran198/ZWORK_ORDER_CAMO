CLASS zcl_work_order_auth_test_camo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_work_order_auth_test_camo IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    out->write( '========================================' ).
    out->write( 'AUTHORIZATION TEST - CAMO' ).
    out->write( '========================================' ).

    " ============================================================
    " 01 - CREATE
    " ============================================================

    AUTHORITY-CHECK OBJECT 'ZAWORKCAMO'
      ID 'ACTVT' FIELD '01'.

    DATA(lv_create_subrc) = sy-subrc.

    out->write(
      |ACTVT 01 - CREATE  - SY-SUBRC: { lv_create_subrc }|
    ).


    " ============================================================
    " 02 - CHANGE
    " ============================================================

    AUTHORITY-CHECK OBJECT 'ZAWORKCAMO'
      ID 'ACTVT' FIELD '02'.

    DATA(lv_change_subrc) = sy-subrc.

    out->write(
      |ACTVT 02 - CHANGE  - SY-SUBRC: { lv_change_subrc }|
    ).


    " ============================================================
    " 03 - DISPLAY
    " ============================================================

    AUTHORITY-CHECK OBJECT 'ZAWORKCAMO'
      ID 'ACTVT' FIELD '03'.

    DATA(lv_display_subrc) = sy-subrc.

    out->write(
      |ACTVT 03 - DISPLAY - SY-SUBRC: { lv_display_subrc }|
    ).


    " ============================================================
    " 06 - DELETE
    " ============================================================

    AUTHORITY-CHECK OBJECT 'ZAWORKCAMO'
      ID 'ACTVT' FIELD '06'.

    DATA(lv_delete_subrc) = sy-subrc.

    out->write(
      |ACTVT 06 - DELETE  - SY-SUBRC: { lv_delete_subrc }|
    ).

    out->write( '========================================' ).

  ENDMETHOD.

ENDCLASS.

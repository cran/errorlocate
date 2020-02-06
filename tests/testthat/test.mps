* Problem:
* Class:      MIP
* Rows:       6
* Columns:    4 (2 integer, 2 binary)
* Non-zeros:  10
* Format:     Fixed MPS
*
NAME
ROWS
 N  R0000000
 L  R0000001
 L  R0000002
 L  R0000003
 L  R0000004
 L  R0000005
 L  R0000006
COLUMNS
    C0000001  R0000005            -1   R0000003             1
    C0000001  R0000001            -1
    C0000002  R0000006            -1   R0000004             1
    C0000002  R0000002            -1
    M0000001  'MARKER'                 'INTORG'
    C0000003  R0000000  1.2780973406   R0000005       -100000
    C0000003  R0000003       -100000
    C0000004  R0000000  1.2333870477   R0000006       -100000
    C0000004  R0000004       -100000
    M0000002  'MARKER'                 'INTEND'
RHS
    RHS1      R0000003            -1   R0000004             1
    RHS1      R0000005             1   R0000006            -1
BOUNDS
 FR BND1      C0000001
 FR BND1      C0000002
 UP BND1      C0000003             1
 UP BND1      C0000004             1
ENDATA

      *===============================================================*
      * PROGRAM  : AUDIT-REPO.cbl
      * PURPOSE  : Output Adapter - Writes physically to audit log
      * AUTHOR   : Jhon Hanco (TheSrJohns)
      * GITHUB   : https://github.com/TheSrJohns
      * ARCHITECTURE LAYER : Infrastructure / Output Adapter
      *===============================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. AUDIT-REPO.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT AUDIT-LOG ASSIGN TO WS-LOG-FILENAME
             ORGANIZATION IS LINE SEQUENTIAL
             FILE STATUS IS WS-LOG-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  AUDIT-LOG.
       01  LOG-RECORD              PIC X(512).

       WORKING-STORAGE SECTION.
       COPY "AUTH-DTO.cpy".

       01  WS-LOG-FILENAME         PIC X(255) VALUE
           "data/logs/audit.log".
       01  WS-LOG-STATUS           PIC X(2)  VALUE SPACES.
           88  WS-LOG-OK           VALUE "00".
       01  WS-LOG-LINE             PIC X(512) VALUE SPACES.
       01  WS-SEPARATOR            PIC X(1)  VALUE '|'.

       LINKAGE SECTION.
       01  LS-OPERATION            PIC X(10).
       01  LS-DTO.
           COPY "AUTH-DTO.cpy" REPLACING ==01  AUTH-REQUEST-DTO== BY
                                                ==05  LS-REQUEST==
                                                ==01  AUTH-RESPONSE-DTO== BY
                                                ==05  LS-RESPONSE==.

       PROCEDURE DIVISION USING LS-OPERATION, LS-DTO.
       MAIN-SECTION.
           EVALUATE LS-OPERATION
               WHEN "INIT"
                   PERFORM INIT-REPO
               WHEN "WRITE"
                   PERFORM WRITE-AUDIT-RECORD
               WHEN "TERM"
                   PERFORM TERM-REPO
               WHEN OTHER
                   DISPLAY "[AUDIT] Unknown operation: " LS-OPERATION
           END-EVALUATE
           GOBACK.

       INIT-REPO.
           DISPLAY "[AUDIT] Audit repository initialized."
           DISPLAY "[AUDIT] Target: " WS-LOG-FILENAME
           .

       WRITE-AUDIT-RECORD.
           DISPLAY "[AUDIT] Persisting transaction: "
                   DTO-TRANSACTION-ID OF LS-DTO

           STRING FUNCTION CURRENT-DATE
                  WS-SEPARATOR
                  DTO-TRANSACTION-ID OF LS-DTO
                  WS-SEPARATOR
                  DTO-CARD-MASKED OF LS-DTO
                  WS-SEPARATOR
                  DTO-AMOUNT OF LS-DTO
                  WS-SEPARATOR
                  DTO-CURRENCY OF LS-DTO
                  WS-SEPARATOR
                  DTO-MERCHANT-ID OF LS-DTO
                  WS-SEPARATOR
                  DTO-STATUS-CODE OF LS-DTO
                  WS-SEPARATOR
                  DTO-STATUS-MSG OF LS-DTO
              DELIMITED BY SIZE
              INTO WS-LOG-LINE

           OPEN EXTEND AUDIT-LOG
           IF WS-LOG-OK
               WRITE LOG-RECORD FROM WS-LOG-LINE
               CLOSE AUDIT-LOG
               DISPLAY "[AUDIT] Record written successfully."
           ELSE
               DISPLAY "[AUDIT] Write error: " WS-LOG-STATUS
           END-IF
           .

       TERM-REPO.
           DISPLAY "[AUDIT] Audit repository closed."
           .

      *===============================================================*
      * PROGRAM  : JSON-SERVICE.cbl
      * PURPOSE  : Input Adapter - Reads physical files and parses JSON
      * AUTHOR   : Jhon Hanco (TheSrJohns)
      * GITHUB   : https://github.com/TheSrJohns
      * ARCHITECTURE LAYER : Infrastructure / Input Adapter
      *===============================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. JSON-SERVICE.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT JSON-FILE ASSIGN TO WS-FILENAME
             ORGANIZATION IS LINE SEQUENTIAL
             FILE STATUS IS WS-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  JSON-FILE.
       01  JSON-RECORD             PIC X(512).

       WORKING-STORAGE SECTION.
       COPY "AUTH-DTO.cpy".

       01  WS-FILENAME             PIC X(255) VALUE
           "data/input/auth-request.json".
       01  WS-FILE-STATUS          PIC X(2)  VALUE SPACES.
           88  WS-FILE-OK          VALUE "00".
           88  WS-FILE-NOT-FOUND   VALUE "35".
       01  WS-EOF-FLAG             PIC X(1)  VALUE 'N'.
           88  WS-EOF              VALUE 'Y'.
       01  WS-RECORD-BUFFER        PIC X(512) VALUE SPACES.

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
               WHEN "POLL"
                   PERFORM POLL-AND-PARSE
               WHEN OTHER
                   DISPLAY "[JSON] Unsupported operation: " LS-OPERATION
           END-EVALUATE
           GOBACK.

       POLL-AND-PARSE.
           DISPLAY "[JSON] Polling file: " WS-FILENAME
           OPEN INPUT JSON-FILE
           IF WS-FILE-OK
               PERFORM READ-JSON-RECORD
               CLOSE JSON-FILE
               PERFORM PARSE-JSON-TO-DTO
               MOVE "OK" TO DTO-STATUS-CODE OF LS-DTO
           ELSE
               IF WS-FILE-NOT-FOUND
                   MOVE "NF" TO DTO-STATUS-CODE OF LS-DTO
                   DISPLAY "[JSON] File not found."
               ELSE
                   MOVE "ER" TO DTO-STATUS-CODE OF LS-DTO
                   DISPLAY "[JSON] File error: " WS-FILE-STATUS
               END-IF
           END-IF
           .

       READ-JSON-RECORD.
           READ JSON-FILE INTO WS-RECORD-BUFFER
               AT END
                   SET WS-EOF TO TRUE
                   DISPLAY "[JSON] Empty file."
               NOT AT END
                   DISPLAY "[JSON] Raw JSON: "
                           FUNCTION TRIM(WS-RECORD-BUFFER)
           END-READ
           .

       PARSE-JSON-TO-DTO.
      *    Simulated JSON parsing (in real world use C$JSON or regex)
           DISPLAY "[JSON] Parsing JSON payload..."
           MOVE "TXN-550e8400-e29b-41d4-a716-446655440000"
             TO DTO-TRANSACTION-ID OF LS-DTO
           MOVE "4532015112830366"
             TO DTO-CARD-NUMBER OF LS-DTO
           MOVE 1250.00
             TO DTO-AMOUNT OF LS-DTO
           MOVE "USD"
             TO DTO-CURRENCY OF LS-DTO
           MOVE "MERCH-ACME-001"
             TO DTO-MERCHANT-ID OF LS-DTO
           MOVE "ACME Corporation"
             TO DTO-MERCHANT-NAME OF LS-DTO
           MOVE FUNCTION CURRENT-DATE
             TO DTO-TIMESTAMP OF LS-DTO
           DISPLAY "[JSON] DTO populated from JSON."
           .

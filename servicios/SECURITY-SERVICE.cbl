      *===============================================================*
      * PROGRAM  : SECURITY-SERVICE.cbl
      * PURPOSE  : Pure Business Logic (e.g., card masking, validation)
      * AUTHOR   : Jhon Hanco (TheSrJohns)
      * GITHUB   : https://github.com/TheSrJohns
      * ARCHITECTURE LAYER : Business Logic / Core
      *===============================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. SECURITY-SERVICE.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY "AUTH-DTO.cpy".

       01  WS-MASK-CHAR            PIC X(1)  VALUE '*'.
       01  WS-MASK-LENGTH          PIC 9(2)  VALUE 12.
       01  WS-IDX                  PIC 9(2)  VALUE ZEROES.
       01  WS-AMOUNT-LIMIT         PIC 9(10)V99 VALUE 99999999.99.

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
                   PERFORM INIT-SERVICE
               WHEN "PROCESS"
                   PERFORM PROCESS-SECURITY-RULES
               WHEN "TERM"
                   PERFORM TERM-SERVICE
               WHEN OTHER
                   DISPLAY "[SECURITY] Unknown operation: " LS-OPERATION
           END-EVALUATE
           GOBACK.

       INIT-SERVICE.
           DISPLAY "[SECURITY] Service initialized."
           DISPLAY "[SECURITY] Masking rules loaded (show last 4)."
           DISPLAY "[SECURITY] Amount limit set to " WS-AMOUNT-LIMIT
           .

       PROCESS-SECURITY-RULES.
           DISPLAY "[SECURITY] Applying rules to TX: "
                   DTO-TRANSACTION-ID OF LS-DTO
      *    Rule 1: Mask card number (keep last 4 digits)
           PERFORM MASK-CARD-NUMBER
      *    Rule 2: Validate amount threshold
           PERFORM VALIDATE-AMOUNT
      *    Rule 3: Enrich status
           MOVE "OK" TO DTO-STATUS-CODE OF LS-DTO
           MOVE "Transaction validated and masked."
               TO DTO-STATUS-MSG OF LS-DTO
           .

       MASK-CARD-NUMBER.
           MOVE DTO-CARD-NUMBER OF LS-DTO
             TO DTO-CARD-MASKED OF LS-DTO
      *    Replace all but last 4 with asterisks
           COMPUTE WS-MASK-LENGTH =
               FUNCTION LENGTH(DTO-CARD-NUMBER OF LS-DTO) - 4
           PERFORM VARYING WS-IDX FROM 1 BY 1
               UNTIL WS-IDX > WS-MASK-LENGTH
               MOVE WS-MASK-CHAR
                 TO DTO-CARD-MASKED OF LS-DTO(WS-IDX:1)
           END-PERFORM
           DISPLAY "[SECURITY] Card masked: "
                   DTO-CARD-MASKED OF LS-DTO
           .

       VALIDATE-AMOUNT.
           IF DTO-AMOUNT OF LS-DTO > WS-AMOUNT-LIMIT
               MOVE "ER" TO DTO-STATUS-CODE OF LS-DTO
               MOVE "Amount exceeds limit."
                   TO DTO-STATUS-MSG OF LS-DTO
               DISPLAY "[SECURITY] AMOUNT VALIDATION FAILED"
           ELSE
               DISPLAY "[SECURITY] Amount validated: "
                       DTO-AMOUNT OF LS-DTO
           END-IF
           .

       TERM-SERVICE.
           DISPLAY "[SECURITY] Service terminated."
           .

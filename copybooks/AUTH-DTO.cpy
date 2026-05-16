      *===============================================================*
      * COPYBOOK : AUTH-DTO.cpy
      * PURPOSE  : Pure Data Definition (DTO) for Payment Auth
      * AUTHOR   : Jhon Hanco (TheSrJohns)
      * GITHUB   : https://github.com/TheSrJohns
      * ARCHITECTURE LAYER : Models / DTOs
      *===============================================================*
       01  AUTH-REQUEST-DTO.
           05  DTO-TRANSACTION-ID    PIC X(36) VALUE SPACES.
           05  DTO-CARD-NUMBER       PIC X(19) VALUE SPACES.
           05  DTO-CARD-MASKED       PIC X(19) VALUE SPACES.
           05  DTO-AMOUNT            PIC 9(10)V99 VALUE ZEROES.
           05  DTO-CURRENCY          PIC X(3)  VALUE SPACES.
           05  DTO-MERCHANT-ID       PIC X(20) VALUE SPACES.
           05  DTO-MERCHANT-NAME     PIC X(50) VALUE SPACES.
           05  DTO-TIMESTAMP         PIC X(20) VALUE SPACES.
           05  DTO-STATUS-CODE       PIC X(2)  VALUE SPACES.
           05  DTO-STATUS-MSG        PIC X(100) VALUE SPACES.

       01  AUTH-RESPONSE-DTO.
           05  RES-TRANSACTION-ID    PIC X(36) VALUE SPACES.
           05  RES-STATUS            PIC X(2)  VALUE SPACES.
           05  RES-MESSAGE           PIC X(100) VALUE SPACES.
           05  RES-MASKED-CARD       PIC X(19) VALUE SPACES.
           05  RES-PROCESSED-AT      PIC X(20) VALUE SPACES.

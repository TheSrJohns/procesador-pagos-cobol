      *===============================================================*
      * PROGRAM  : EVENT-DAEMON.cbl
      * PURPOSE  : Event Loop Orchestrator (The "Boss")
      *            Watches clock, polls input, delegates to services.
      * AUTHOR   : Jhon Hanco (TheSrJohns)
      * GITHUB   : https://github.com/TheSrJohns
      * ARCHITECTURE LAYER : Presentation / Controller
      *===============================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. EVENT-DAEMON.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. LINUX.
       OBJECT-COMPUTER. LINUX.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INPUT-DIR ASSIGN TO "data/input/"
             ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  INPUT-DIR.
       01  DIR-RECORD PIC X(255).

       WORKING-STORAGE SECTION.
       COPY "AUTH-DTO.cpy".

       01  WS-CONSTANTS.
           05  WS-POLL-INTERVAL-SEC  PIC 9(2)  VALUE 5.
           05  WS-MAX-RETRIES        PIC 9(2)  VALUE 3.
           05  WS-EOF-FLAG           PIC X(1)  VALUE 'N'.
               88  WS-EOF            VALUE 'Y'.

       01  WS-STATE.
           05  WS-CURRENT-FILE       PIC X(255) VALUE SPACES.
           05  WS-RETRY-COUNT        PIC 9(2)  VALUE ZEROES.
           05  WS-EVENT-COUNT        PIC 9(6)  VALUE ZEROES.
           05  WS-LOOP-ACTIVE        PIC X(1)  VALUE 'Y'.
               88  WS-KEEP-RUNNING   VALUE 'Y'.
               88  WS-STOP           VALUE 'N'.

       01  WS-TIMESTAMP.
           05  WS-DATE               PIC X(10) VALUE SPACES.
           05  FILLER                PIC X(1)  VALUE ' '.
           05  WS-TIME               PIC X(8)  VALUE SPACES.

       PROCEDURE DIVISION.
       MAIN-SECTION.
           DISPLAY "========================================"
           DISPLAY " EVENT-DAEMON v1.0.0 "
           DISPLAY " Author : Jhon Hanco (TheSrJohns)"
           DISPLAY " Repo   : procesador-pagos-cobol"
           DISPLAY " Layer  : Controller / Orchestrator"
           DISPLAY "========================================"
           DISPLAY "[DAEMON] Starting event loop..."

           PERFORM INITIALIZE-SYSTEM
           PERFORM UNTIL WS-STOP
               PERFORM GET-CURRENT-TIMESTAMP
               DISPLAY "[DAEMON] Poll cycle at " WS-DATE " " WS-TIME
               PERFORM POLL-INPUT-FILES
               CALL 'C$SLEEP' USING WS-POLL-INTERVAL-SEC
           END-PERFORM

           PERFORM SHUTDOWN-SYSTEM
           DISPLAY "[DAEMON] Event loop terminated gracefully."
           GOBACK.

       INITIALIZE-SYSTEM.
           DISPLAY "[DAEMON] Initializing subsystems..."
           CALL "SECURITY-SERVICE" USING "INIT", AUTH-REQUEST-DTO
           CALL "AUDIT-REPO"        USING "INIT", AUTH-REQUEST-DTO
           DISPLAY "[DAEMON] All subsystems ready."
           .

       POLL-INPUT-FILES.
           DISPLAY "[DAEMON] Scanning data/input/ for JSON events..."
      *    In real GnuCOBOL, use SYSTEM to ls or C library calls.
      *    Here we simulate the delegation to JSON-SERVICE adapter.
           CALL "JSON-SERVICE" USING "POLL", AUTH-REQUEST-DTO
           IF DTO-STATUS-CODE = "OK"
               ADD 1 TO WS-EVENT-COUNT
               DISPLAY "[DAEMON] Event #" WS-EVENT-COUNT
                       " received: " DTO-TRANSACTION-ID
               PERFORM PROCESS-EVENT
           ELSE
               DISPLAY "[DAEMON] No new events."
           END-IF
           .

       PROCESS-EVENT.
           DISPLAY "[DAEMON] Delegating to SECURITY-SERVICE..."
           CALL "SECURITY-SERVICE" USING "PROCESS", AUTH-REQUEST-DTO

           DISPLAY "[DAEMON] Delegating to AUDIT-REPO..."
           CALL "AUDIT-REPO" USING "WRITE", AUTH-REQUEST-DTO

           DISPLAY "[DAEMON] Event " DTO-TRANSACTION-ID
                   " processed successfully."
           .

       GET-CURRENT-TIMESTAMP.
           MOVE FUNCTION CURRENT-DATE(1:10) TO WS-DATE
           MOVE FUNCTION CURRENT-DATE(12:8)  TO WS-TIME
           .

       SHUTDOWN-SYSTEM.
           DISPLAY "[DAEMON] Shutting down subsystems..."
           CALL "SECURITY-SERVICE" USING "TERM", AUTH-REQUEST-DTO
           CALL "AUDIT-REPO"        USING "TERM", AUTH-REQUEST-DTO
           DISPLAY "[DAEMON] Total events processed: " WS-EVENT-COUNT
           .

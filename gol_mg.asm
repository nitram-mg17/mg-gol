;File name:     gol_mg.asm
;Created by:    Martin Gonzales
;Date:          05/13/2020

.model large ;multiple data and stack
.386 ;fixes out of byte range
.stack 256
    pixelcolor equ 0Ch  ; Light red color
    escape equ 1Bh      ; "esc"
    space equ 20h       ; "space bar"
    bspace equ 08h      ; "backspace"
    enterkey equ 0Dh    ; "enter"
    loadkey equ 6Ch     ; "l"
    restartkey equ 72h  ; "r"
    savekey equ 73h     ; "s"

.data
    ;vid data supposed to be 320x200 = 64000
    viddata db 64500 dup(0)  ;fix graphic pixel errors
    x_click dw 0; x value at mouse click
    y_click dw 0; y value at mouse click
    stat_click dw ? ;value of BX for int33h
    filen db "save.txt",0 ;will be used to save filename
    filehandler dw ?    ;for s
    
    ;title screen line variables
    tsline0 db ' ________     _______     _         $'
    tsline1 db '|  ______|   /  ___  \   | |        $'
    tsline2 db '| |         |  /   \  |  | |        $'
    tsline3 db '| |   ___   | |     | |  | |        $'
    tsline4 db '| |  |_  |  | |     | |  | |        $'
    tsline5 db '| |____| |  |  \___/  |  | |______  $'
    tsline6 db '|________|   \_______/   |________| $'
    tsline7 db '     Welcome to My Game of Life     $'
    tsline8 db '        by: Martin Gonzales         $'
    tsline9 db '                                    $'
    tslineA db 'Instructions:$'
    tslineB db 'Left Clk/Drag  -   Input Cell$'
    tslineC db 'Right Click    -   LEAVE INPUT$'
    tslineD db 'Space Bar      -   Next Gen$'
    tslineE db 'Enter          -   Get Mouse$'
    tslineF db 'Back Space     -   Clear Screen$'
    tslineG db 'Escape         -   Exit Game$'

    ;exit screen line variables
    esline0 db '            __________              $'
    esline1 db '           /          \             $'
    esline2 db '          |  .|.  .|.  |            $'
    esline3 db '          |            |            $'
    esline4 db '          |  \______/  |            $'
    esline5 db '          |     \_/    |            $'
    esline6 db '           \__________/             $'
    esline7 db '              SURPRISE!             $'
    esline8 db '        THANK YOU FOR PLAYING!      $'
    esline9 db ' PRESS "L" x2 TO RETURN TO LAST SAVE$'
    eslineA db ' PRESS "R" x2 TO RESTART GAME       $'
    eslineB db ' PRESS "ESC"  TO EXIT PROGRAM       $'

    ;macro_name macro [parameters...]

    ;tscursor(int x, int y) title screen cursor
    screencursor macro x,y
        MOV AH,2 ;set cursor positon
        MOV BH,0 ;graphics mode page number
        MOV DL,x ;DL for columns
        MOV DH,y ;DH for rows
        INT 10h
    endm

    ;print(string data, int x, int y)
    print macro datastring,x,y      
        screencursor x,y                ;gives position
        MOV AH,09h                 ;print string
        MOV DX,offset datastring
        INT 21h
    endm
    ;printTitlescreen()
    printTitleScreen macro   ;dimensions (40x25) from int21h
        print tsline0,3,1
        print tsline1,3,2
        print tsline2,3,3
        print tsline3,3,4
        print tsline4,3,5
        print tsline5,3,6
        print tsline6,3,7
        print tsline7,2,9
        print tsline8,1,12
        print tsline9,1,14
        print tslineA,1,16
        print tslineB,1,17
        print tslineC,1,18
        print tslineD,1,19
        print tslineE,1,20
        print tslineF,1,21
        print tslineG,1,22
        MOV AH,0            ;wait for keyboard input
        INT 16h
        CMP al, escape      ;press ESC to exit
        JE exit
        ;CMP al, loadkey
        ;JE loadGame
    endm

    ;printExitscreen()
    printExitScreen macro   ;dimensions (40x25) from int21h
        print esline0,3,1
        print esline1,3,2
        print esline2,3,3
        print esline3,3,4
        print esline4,3,5
        print esline5,3,6
        print esline6,3,7
        print esline7,2,9
        print esline8,1,11
        print esline9,1,14
        print eslineA,1,16
        print eslineB,1,18
        MOV AH,0            ;wait for keyboard input
        INT 16h
        CMP al, escape      ;press ESC to exit
        JE real_exit
    endm

.code

startProgram:           ;first function to be called
    MOV AH,0            ;set video config
    MOV AL,13h
    INT 10h             
    printTitleScreen    ;print title screen
RET

exitProgram:            ;function to jump to exit page
    MOV AH,0            ;set video config
    MOV AL,13h
    INT 10h
    printExitScreen     ;pritn exit screen
RET

drawCell:
    MOV AH,0Ch          ;set writing config mode
    MOV AL,pixelcolor   ;set color of pixel
    MOV BH,0            ;set pg #
    MOV CX,x_click      ;x coordinate
    MOV DX,y_click      ;y coordinate
    INT 10h
ret

checkNeighbor:
    ;AX will be used as counter of surrounding neighbors
    ;Since my screen is 320x200, in order to follow the
    ;index,I must add/sub 320 to traverse the y axis and
    ;and add/sub 1 to traverse the x axis
    ;NOTE: index will be 320x200 = 64000;
    
    MOV AX,0;counter

    UL: ;upper left
    SUB DI,321                  
    CMP byte ptr ES:[DI],0
    JZ ML
    INC AX

    ML: ;middle left
    ADD DI,320
    CMP byte ptr ES:[DI],0
    JZ LL
    INC AX

    LL: ;lower left
    ADD DI,320
    CMP byte ptr ES:[DI],0
    JZ UM
    INC AX

    UM: ;upper mid
    SUB DI,639
    CMP byte ptr ES:[DI],0
    JZ LM
    INC AX

    LM: ;lower mid
    ADD DI,640
    CMP byte ptr ES:[DI],0
    JZ UR
    INC AX

    UR: ;upper right
    SUB DI,639
    CMP byte ptr ES:[DI],0
    JZ MR
    INC AX

    MR: ;middle right
    ADD DI,320
    CMP byte ptr ES:[DI],0
    JZ LR
    INC AX

    LR: ;lower right
    ADD DI,320
    CMP byte ptr ES:[DI],0
    JNZ incNCounter
RET

incNCounter:
    INC AX
RET

gotoCell:
    ;go to cell index
    ;index(DI) is from 0 to 63999, we must multiply
    ;y by 320 to easily traverse the y-axis
    ;Every increase of 320 in x is equals to 1 in y.
    MOV AX,CX             ;mul only works for AX
    MOV BX,320            
    MOV stat_click, DX    ;save DX from mul
    MUL BX                ;AX=CX*320
    XCHG DX,stat_click    ;get original DX
    MOV BX,DX             ;copy DX to BX
    MOV DI,AX             
    ADD DI,BX             ;DI = CX*320+DX
    ;now DI is pointing at actual cell
RET

;next generation system
nextGenSystem:
    ;save register values that will be used
    ;AX,CX,DX,BX,DI,DS
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH BX
    PUSH DI
    PUSH DS

    MOV CX,0 ;set y = 0
    MOV DI,0 ;set index of ES to 0
    MOV DX,DS
    MOV AX,offset viddata ;copy address of viddata to AX
    ADD AX,DX ;set address of DX to AX
    MOV DS,AX ;store address to DS

    ;Loop Traversal
    ;for(int i...) for (int j...)
    ;We will use CX as counter for Y axis, DX for X axis
    ;And use nested for loops to check all pixel
    forLoopY:
    INC CX                    ;CX++ to end loop at some point (199)
    MOV DX,0                  ;set Y axis to always start at 0
    CMP CX,199                ;check if CX is at 200 (note that range goes from 0-199)
    JNE forLoopX              ;nest to for loop of x axis if not at max value of y
    JMP endLoop               ;end the loop once we traveresed all y axis
        
    ;nested for loop 
    forLoopX:
    INC DX ; DX++ to end loop at 319 for x axis
    CMP DX,319 ;check if DX is at max range
    JE forLoopY ;end the x loop then go back to y loop
    
    ;for loop instructions
    CALL gotoCell                   ;get the cell index
    CALL checkNeighbor              ;check the surrounding neighbors
    SUB DI,321                      ;return pointer to original cell
    CMP byte ptr ES:[DI],0          ;Check if current cell dead
    JE itsDead                      ;if =, its alive, jump to check

    ;NOTE:
    ;If Alive, must have 2-3 neighbors to survive
    ;If Dead, must have "EXACTLY" 3 neighbors to survive

    itsAlive:
    ;if AX <=1, remove
    CMP AX,1
    JLE removeCell
    ;else if AX = 2, keep cell
    CMP AX,2
    JE putCell
    ;else if AX = 3, keep cell
    CMP AX,3
    JE putCell
    ;else remove cell
    JMP removeCell

    itsDead:
    ;if AX = 3, then revive, else dead
    CMP AX,3
    JE putCell
    JMP forLoopX     ;since its dead, we can return to loop

    putCell:
    ;put a pixel on cell
    MOV byte ptr DS:[DI], pixelcolor;
    JMP forLoopX     ;return to loop once pixel is put

    removeCell:
    ;remove a pixel on cell
    MOV byte ptr DS:[DI],0
    JMP forLoopX     ;return to loop once pixel is removed

    endLoop:
    ;copy the data to screen and
    ;load original registers
    call loadVideoData
    POP DS
    POP DI
    POP BX
    POP DX
    POP CX
    POP AX
RET

;load the data into the screen after doing next generation
loadVideoData:
    ;we will use CX, DI, and SI in this process
    ;therefore, we must save original registers
    PUSH CX
    PUSH DI
    PUSH SI
    ;empty SI DI
    MOV SI,0
    MOV DI,0
    ;320x200=64000, we must load every window pixel
    MOV CX, 64000       ;CX will loop 64000 times
    CLD                 ;Clear direction flag (recommended from notes)
    copyDStoES:
    MOVSB;              ;copies string DS data into ES
    LOOP copyDStoES
    ;get the original value
    POP SI
    POP DI
    POP CX
RET

;return to last seen generation before exit
loadLast:
    MOV ax,13h          ;reset screen
    INT 10h
    JMP generationLoop  ;set last seen screen
    RET


;loadGame:
;    mov ah,3dh
;    mov al,1
;    mov dx,offset filen
;    mov ax,filehandler
;    jmp loadpoint
;ret


start:
    ;Clear registers (better than doing MOV reg,0)
    XOR AX, AX
    XOR BX, BX
    XOR CX, CX
    XOR DX, DX
    XOR SI, SI
    XOR DI, DI
    XOR SP, SP
    MOV AX,@data    ;save data to accumulator AX
    MOV DS,AX    ;copy AX to DX
    CALL startProgram ;set the title screen
    MOV AX,0A000h ;initialize video memory
    MOV ES,AX   ;set ES as location of video memory
    
    
    ;save on existing file (already made)
    ;saveGame:
    ;mov ah,3dh
    ;mov al,1
    ;mov dx,offset filen
    ;int 21h
    ;jc real_exit
    ;mov filehandler,ax

    ;mov ah,40h
    ;mov bx,filehandler
    ;mov cx,64000
    ;mov dx,offset viddata
    ;int 21h
    ;jc real_exit

    resetScreen:
    MOV AH,00h ;set config of video mode
    MOV AL,13h ;choose video mode 320x200
    INT 10h    

    MOV AH,0Bh ;set config of video mode
    MOV BH,00h ;to the background color
    MOV BL,00h ;choose color (black)
    INT 10h    

    ;Reset viddata and video memory ES:[BX]
    MOV CX,64000 ;loop counter
    setMemoryZero:
    MOV BX,CX ;must copy to BX (requires Base register)
    MOV byte ptr viddata[BX], 0
    MOV byte ptr ES:[BX], 0
    LOOP setMemoryZero
    
    loadpoint: ;ideally

    ;set mouse coordinates X axis (0-320)
    MOV AX,7
    MOV CX,0    ;min
    MOV DX,320  ;max
    INT 33h
    ;set mouse coordinates Y axis (0-200)
    MOV AX,8
    MOV CX,0    ;min
    MOV DX,200  ;max
    INT 33h

    ;initialize mouse
    resetMouse:
    MOV AX,0
    INT 33h
    MOV CX,0 ;put mouse position
    MOV DX,0 ;in the upper-leftmost
    MOV AX,4 ;corner
    INT 33h
    
    
    MOV BX,0 ;set bx for mouse input

    initialBoardConfig:
    MOV AX,1 ;show mouse
    INT 33h
    MOV ax,03
    INT 33h
    MOV y_click,DX      ;save dx to y
    MOV stat_click,BX   ;save bx to stat for mouse
    PUSH AX             ;save AX and BX to stack
    PUSH BX             
    MOV AX,CX           ;we want to divide CX(x axis)
    MOV BX,2            ;by 2 since original resolution
    XOR DX,DX           ;of mouse is 640x200, while this
    DIV BX              ;program has 320,200 resolution
    MOV x_click,AX
    POP BX              ;retrieve original AX and BX
    POP AX
    CMP BX,2            ;right click gives output to BX of 2
                        ;note: i want the middle click for exit but could
                        ;not figure it out.
    JE exitInitConfig        ;leave input config after right click
    CMP BX,1
    JNE initialBoardConfig
    mov ax,2            ;hide mouse since it affects writing pixels
    int 33h             
    CALL drawCell        ;draw the pixel on the mouseclick
    JMP initialBoardConfig
    
    exitInitConfig:
    MOV ax,2            ;hide mouse after finishing   
    INT 33h             ;the initial configuration
    wait1:
    MOV ax,0            ;wait for user to press key
    INT 16h
    CMP AL,space     ;start next generation
    JE generationLoop
    CMP al,enterkey        ;summon mouse
    JE resetMouse
    CMP al,bspace       ;reset/clear screen
    JE resetScreen
    CMP al,escape       ;exit
    JE exit
    JMP wait1           ;return to wait1 for key
                        ;must press the specified keys
    
    generationLoop:
    CALL nextGenSystem         ;where the magic happens
    wait2:
    MOV AH,00            ;wait for key
    INT 16h
    CMP AL,bspace        ;press backspace to clear screen
    JE resetScreen
    CMP AL, enterkey        ;press enter to summon mouse for input
    JE resetMouse
    CMP AL, space     ;press enter for next generation
    JE generationLoop
    CMP AL, escape       ;press ESC to exit
    JE exit
    CMP AL, savekey
    JE saveGame
    JMP wait2            ;return back to wait2 for key
                         ;should press the specified keys


    ;save on existing file (already made)
    saveGame:
    mov ah,3dh              ;op code for file
    mov al,1                ;write only
    mov dx,offset filen     ;dx points to file
    int 21h
    jc real_exit            ;exit if error
    mov filehandler,ax

    mov ah,40h              ;write to file
    mov bx,filehandler
    mov cx,64000            ;amount of bytes to write
    mov dx,offset viddata   ;data to write
    int 21h
    jc real_exit            ;exit for any errors
    jmp wait2

    ;exit: returns to command line
    exit:
    CALL exitProgram
    MOV AX,0
    INT 16h
    CMP AL, restartkey 
    JE resetScreen
    CMP AL, escape
    JE real_exit
    CMP AL, loadkey
    JE loadLast
    ;real exit
    real_exit:
    MOV AX,3
    INT 10h
    MOV AX,4c00h
    INT 21h
end start

;REFERENCES:
;
;*** macros
;https://jbwyatt.com/253/emu/asm_tutorial_10.html
;*** .386 directive
;https://stackoverflow.com/questions/39427980/relative-jump-out-of-range-by
;*** copying string to string (ES=DS) multiple times - MOVSB
;https://faculty.kfupm.edu.sa/COE/aimane/assembly/pagegen-139.aspx.htm
;*** interupt calls
;https://stanislavs.org/helppc/idx_assembler.html
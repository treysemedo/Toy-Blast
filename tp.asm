;--------------------------------------------------------------
; Demostra��o da navega��o do Ecran com um avatar
;
;--------------------------------------------------------------

.8086
.model small
.stack 2048

PILHA	SEGMENT PARA STACK 'STACK'
		db 2048 dup(?)
PILHA	ENDS

dseg	segment para public 'data'
		End_Msg			db		"Parabens, concluiu o labirinto!",0Dh,0Ah
						db		"Demorou:             a concluir o labirinto."
						db		'$'
		TEMPO	 		db 		"                   "	; String para 20 digitos
		TEMP	 		db 		"       "	; String para 6 digitos
		menu    		db      10, 13, 10, 13, "*************Jogo_de_Labirinto****************",0Dh,0Ah,0Dh,0Ah,09h
						db      "1 - Jogar",0Dh,0Ah,09h
						db      "2 - Top 10",0Dh,0Ah,09h     
						db      "3 - Configuracao do Labirinto",0Dh,0Ah,09h
						db      "4 - Sair",0Dh,0Ah,09h
						db      "Digite um numero: "
						db      '$'		
		
		sub_menu		db		10, 13, 10, 13, "*************Configuracao_do_Labirinto*************",0Dh,0Ah,0Dh,0Ah,09h
						db    	"1 - Carregar Labirinto predefindo",0Dh,0Ah,09h    
						db      "2 - Criar Labirinto",0Dh,0Ah,09h
						db      "3 - Editar Labirinto",0Dh,0Ah,09h
						db      "4 - Apagar Labirinto",0Dh,0Ah,09h
						db      "5 - Voltar",0Dh,0Ah,09h
						db      "Digite um numero: "
						db      '$'
		
		sub_menu2		db		10, 13, 10, 13, "*************Jogar*************",0Dh,0Ah,0Dh,0Ah,09h
						db    	"1 - Jogar Labirinto - Lisboa",0Dh,0Ah,09h
						db		"2 - Jogar Labirinto - Coimbra",0Dh,0Ah,09h
						db      "3 - Escolher Labirinto",0Dh,0Ah,09h
						db      "4 - Voltar",0Dh,0Ah,09h
						db      "Digite um numero: "
						db      '$'
		
		top10           db 		"                    "	; String para 20 digitos
						db 		"                    "	; String para 20 digitos
						db 		"                    "	; String para 20 digitos
						db 		"                    "	; String para 20 digitos
						db 		"                    "	; String para 20 digitos
						db 		"                    "	; String para 20 digitos
						db 		"                    "	; String para 20 digitos
						db 		"                    "	; String para 20 digitos
						db 		"                    "	; String para 20 digitos
						db 		"                    "	; String para 20 digitos
						db      '$'
						
		top10_aux      db 		"        "	; String para 7 digitos
						db      '$'	
						
		;########################################################################
		Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
        Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
        Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
        Fich         	db      'linha1.TXT',0
		Fich2         	db      'linha2.TXT',0
        HandleFich      dw      0
        car_fich        db      ?
		;########################################################################
		
		STR12	 		db 		"            "	; String para 12 digitos	
		NUMERO			db		"                    $", 	; String destinada a guardar o n�mero lido
		
	
		NUM_SP			db		"                    $" 	; PAra apagar zona de ecran
		DDMMAAAA 		db		"                     "

		Horas			dw		0				; Vai guardar a HORA actual
		Minutos			dw		0				; Vai guardar os minutos actuais
		Segundos		dw		0				; Vai guardar os segundos actuais
		Old_seg			dw		0				; Guarda os �ltimos segundos que foram lidos
		
		HI				dw		0				; Vai guardar a horas inicial em segundos
		MI				dw		0				; Vai guardar os minutos inicial em segundos
		S				dw		0				; Vai guardar os segundos iniciais
		TI				dw		0				; Vai guardar a hora de inicio
		
		HF				dw		0				; Vai guardar a horas final em segundos
		MF				dw		0				; Vai guardar os minutos final em segundos
		SF				dw		0				; Vai guardar os segundos finais
		TF				dw		0				; Vai guardar a hora de fim
		;########################################################################
		string			db		"Teste pr�tico de T.I",0
		Car				db		32	; Guarda um caracter do Ecran 
		Cor				db		7	; Guarda os atributos de cor do caracter
		POSy			db		1	; a linha pode ir de [1 .. 25]
		POSx			db		1	; POSx pode ir [1..80]	
		POSya			db		0	; Posi��o anterior de y
		POSxa			db		0	; Posi��o anterior de x
		;#######################################################################
		
dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg, ss:PILHA

goto_xy	macro	POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da p�gina
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm

; MOSTRA - Faz o display de uma string terminada em $
;---------------------------------------------------------------------------
MOSTRA 	MACRO 	STR 
		MOV 	AH,09H
		LEA 	DX,STR 
		INT 	21H
ENDM

;########################################################################
;ROTINA PARA APAGAR ECRAN

apaga_ecran	proc
		xor		bx,bx
		mov		cx,25*80
		
apaga:	mov	byte ptr es:[bx],' '
		mov		byte ptr es:[bx+1],7
		inc		bx
		inc 	bx
		loop	apaga
		ret
apaga_ecran	endp


;########################################################################
; LE UMA TECLA	

LE_TECLA	PROC
sem_tecla:
		call 	Trata_Horas
		MOV		AH,0BH
		INT 	21h
		cmp 	AL,0
		je		sem_tecla

		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1
SAI_TECLA:	RET
LE_TECLA	endp

;########################################################################
;########################################################################

Ler_TEMPO PROC	
 
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
	
		PUSHF
		
		MOV AH, 2CH             ; Buscar as HORAS
		INT 21H                 
		
		XOR AX,AX
		MOV AL, DH              ; Segundos para al
		mov Segundos, AX		; guarda SEGUNDOS na variavel correspondente
		
		XOR AX,AX
		MOV AL, CL              ; Minutos para al
		mov Minutos, AX         ; guarda MINUTOS na variavel correspondente
		
		XOR AX,AX
		MOV AL, CH              ; Horas para al
		mov Horas,AX			; guarda HORAS na variavel correspondente
 
		POPF
		POP DX
		POP CX
		POP BX
		POP AX
 		RET 
Ler_TEMPO   ENDP

;########################################################################
;########################################################################

; Imprime o tempo e a data no monitor

Trata_Horas PROC

		PUSHF
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX		

		CALL 	Ler_TEMPO				; Horas MINUTOS e segundos do Sistema
		
		MOV		AX, Segundos
		cmp		AX, Old_seg			; Verifica se os segundos mudaram desde a ultima leitura
		je		fim_horas			; Se a hora n�o mudou desde a �ltima leitura sai.
		mov		Old_seg, AX			; Se segundos s�o diferentes actualiza informa��o do tempo 
		
		mov 	ax,Horas
		MOV		bl, 10     
		div 	bl
		add 	al, 30h				; Caracter Correspondente �s dezenas
		add		ah,	30h				; Caracter Correspondente �s unidades
		MOV 	STR12[0],al			; 
		MOV 	STR12[1],ah
		MOV 	STR12[2],'h'		
		MOV 	STR12[3],'$'
		GOTO_XY 66,1
		MOSTRA STR12 		
        
		mov 	ax,Minutos
		MOV 	bl, 10     
		div 	bl
		add 	al, 30h				; Caracter Correspondente �s dezenas
		add		ah,	30h				; Caracter Correspondente �s unidades
		MOV 	STR12[0],al			; 
		MOV 	STR12[1],ah
		MOV 	STR12[2],'m'		
		MOV 	STR12[3],'$'
		GOTO_XY	70,1
		MOSTRA	STR12 		
		
		mov 	ax,Segundos
		MOV 	bl, 10     
		div 	bl
		add 	al, 30h				; Caracter Correspondente �s dezenas
		add		ah,	30h				; Caracter Correspondente �s unidades
		MOV 	STR12[0],al			; 
		MOV 	STR12[1],ah
		MOV 	STR12[2],'s'		
		MOV 	STR12[3],'$'
		GOTO_XY	74,1
		MOSTRA	STR12	
		
						
fim_horas:

		POPF
		POP DX		
		POP CX
		POP BX
		POP AX
		RET		
			
Trata_Horas ENDP

;########################################################################
;########################################################################

Main  proc
		mov		ax, dseg
		mov		ds, ax
		mov		ax, 0B800h
		mov		es, ax
		
		call	apaga_ecran
		goto_xy	0,0
;########################################################################
;########################################################################
mostrar_menu:
		lea     dx, menu 
		mov     ah, 09h
		int     21h
		
get_num:		
			mov     ah, 1
			int     21h          
			cmp     al, '1'
			je      ShowTerMenu
			cmp     al, '2'
			je      ShowTerMenu
			cmp     al, '3'
			je      ShowSecMenu
			cmp     al, '4'
			jmp     sair
		
ShowSecMenu:
		lea     dx, sub_menu
		mov     ah, 09h
		int     21h

getnum2: 			
		mov     ah, 1
		int     21h          
		cmp     al, '1'
		je      CARREGAR_LABIRINTO  
		cmp     al, '2'
		je      DESENHAR_LABIRINTO
		cmp     al, '3'
		je      CARREGAR_LABIRINTO
		cmp     al, '4'
		je      CARREGAR_LABIRINTO
		cmp     al, '5'
		je      mostrar_menu
		
		jmp sair
		
ShowTerMenu:
		lea     dx, sub_menu2
		mov     ah, 09h
		int     21h
		
getnum3:       
		mov     ah, 1
		int     21h          
		cmp     al, '1'
		je      CARREGAR_LABIRINTO  
		cmp     al, '2'
		je      CARREGAR_LABIRINTO2 
		cmp     al, '3'
		je      CARREGAR_LABIRINTO2
		cmp     al, '4'
		je      mostrar_menu
		
		jmp sair
		
;########################################################################
;########################################################################
CARREGAR_LABIRINTO2:
		call	apaga_ecran
		goto_xy	0,0
        mov     ah,3dh			; vamos abrir ficheiro para leitura 
        mov     al,0			; tipo de ficheiro	
        lea     dx,Fich2			; nome do ficheiro
        int     21h				; abre para leitura 
        jc      erro_abrir		; pode aconter erro a abrir o ficheiro 
        mov     HandleFich,ax	; ax devolve o Handle para o ficheiro 
        jmp     ler_ciclo		; depois de abero vamos ler o ficheiro 
		
CARREGAR_LABIRINTO:
		call	apaga_ecran
		goto_xy	0,0
        mov     ah,3dh			; vamos abrir ficheiro para leitura 
        mov     al,0			; tipo de ficheiro	
        lea     dx,Fich			; nome do ficheiro
        int     21h				; abre para leitura 
        jc      erro_abrir		; pode aconter erro a abrir o ficheiro 
        mov     HandleFich,ax	; ax devolve o Handle para o ficheiro 
        jmp     ler_ciclo		; depois de abero vamos ler o ficheiro 

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     fim

ler_ciclo:
        mov     ah,3fh			; indica que vai ser lido um ficheiro 
        mov     bx,HandleFich	; bx deve conter o Handle do ficheiro previamente aberto 
        mov     cx,1			; numero de bytes a ler 
        lea     dx,car_fich		; vai ler para o local de memoria apontado por dx (car_fich)
        int     21h				; faz efectivamente a leitura
		jc	    erro_ler		; se carry � porque aconteceu um erro
		cmp	    ax,0			; EOF?	verifica se j� estamos no fim do ficheiro 
		je	    fecha_ficheiro	; se EOF fecha o ficheiro 
        mov     ah,02h			; coloca o caracter no ecran
		mov	    dl,car_fich		; este � o caracter a enviar para o ecran
		int	    21h				; imprime no ecran
		jmp	    ler_ciclo		; continua a ler o ficheiro

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:					; vamos fechar o ficheiro 
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     INICIO

        mov     ah,09h			; o ficheiro pode n�o fechar correctamente
        lea     dx,Erro_Close
        Int     21h
;########################################################################
;########################################################################
DESENHAR_LABIRINTO:
		call	apaga_ecran
		mov		POSx,0
		mov		POSy,0
CICLO_DESENHAR:	goto_xy	POSx,POSy
IMPRIME_DESENHAR:
		mov		ah, 02h
		mov		dl, Car
		int		21H			
		goto_xy	POSx,POSy
		
		call 	LE_TECLA
		cmp		ah, 1
		je		ESTEND_DESENHAR
		CMP 	AL, 27		; ESCAPE
		JE		fim

ZERO:	CMP 	AL, 48		; Tecla 0
		JNE		UM
		mov		Car, 32		; ESPA�O
		jmp		CICLO_DESENHAR					
		
UM:		CMP 	AL, 49		; Tecla 1
		JNE		DOIS
		mov		Car, 219	; Caracter CHEIO
		jmp		CICLO_DESENHAR		
	
DOIS:	CMP 	AL, 50		; Tecla 2
		JNE		TRES
		mov		Car, 177	; CINZA 177
		jmp		CICLO_DESENHAR			
		
TRES:	CMP 	AL, 51		; Tecla 3
		JNE		QUATRO
		mov		Car, 178	; CINZA 178
		jmp		CICLO_DESENHAR
		
QUATRO:	CMP 	AL, 52		; Tecla 4
		JNE		NOVE
		mov		Car, 176	; CINZA 176
		jmp		CICLO_DESENHAR
		
NOVE:	jmp		CICLO_DESENHAR
	
ESTEND_DESENHAR:	
		cmp 	al,48h
		jne		BAIXO_DESENHAR
		
		mov		dh, POSy
		cmp		dh, 0		; Restringir cima(igual a esquerda)
		je		BARREIRA
		
		dec		POSy		; Cima
		jmp		CICLO_DESENHAR

BAIXO_DESENHAR:
		cmp		al,50h
		jne		ESQUERDA_DESENHAR
		
		mov		dl, POSy
		cmp		dh, 20		; Restringir baixo(igual a esquerda)
		je		BARREIRA
		
		inc 	POSy		; Baixo
		jmp		CICLO_DESENHAR

ESQUERDA_DESENHAR:
		cmp		al,4Bh
		jne		DIREITA_DESENHAR
		
		mov		dl, POSx	; move a posi��o de x para dl
		cmp		dl, 0		; compara dl(x) com 0
		je		BARREIRA	; salta para barreira se dl for 0
		
		dec		POSx		; Esquerda
		jmp		CICLO_DESENHAR

DIREITA_DESENHAR:
		cmp		al,4Dh
		jne		CICLO_DESENHAR
		
		mov		dl, POSx
		cmp		dl, 40		; Restringir direita(igual a esquerda)
		je		BARREIRA
		
		inc		POSx		; Direita
		jmp		CICLO_DESENHAR

BARREIRA:
		jmp		CICLO_DESENHAR		; salta para o ciclo que faz com que o cursor fique no mesmo sitio
;########################################################################
;########################################################################
INICIO:
		goto_xy	POSx,POSy	; Vai para nova possi��o
		mov 	ah, 08h		; Guarda o Caracter que est� na posi��o do Cursor
		mov		bh, 0		; numero da p�gina
		int		10h			
		mov		Car, al		; Guarda o Caracter que est� na posi��o do Cursor
		mov		Cor, ah		; Guarda a cor que est� na posi��o do Cursor

		call	Ler_TEMPO
		
		mov 	ax,	Horas
		mov		bx,	3600
		mul		bx
		add		ax,	dx
		mov		HI,	ax
		
		mov 	ax,	Minutos
		mov		bx,	60
		mul		bx
		add		ax,	dx
		mov		MI,	ax
		
		mov		ax,	Segundos
		mov		S,	ax
		
		xor		ax,	ax
		xor		dx,	dx
		mov		ax,	HI
		mov		dx,	MI
		add		ax,	dx
		mov		dx,	S
		add		ax,	dx
		mov		TI,	ax
	

CICLO:	goto_xy	POSxa,POSya	; Vai para a posi��o anterior do cursor
		mov		ah, 02h
		mov		dl, Car		; Repoe Caracter guardado 
		int		21H
		
		goto_xy	POSx,POSy	; Vai para nova possi��o
		mov 	ah, 08h
		mov		bh, 0		; numero da p�gina
		int		10h		
		mov		Car, al		; Guarda o Caracter que est� na posi��o do Cursor
		mov		Cor, ah		; Guarda a cor que est� na posi��o do Cursor
		
		goto_xy	78,0		; Mostra o caracter que estava na posi��o do AVATAR
		mov		ah, 02h		; IMPRIME caracter da posi��o no canto
		mov		dl, Car	
		int		21H
	
		goto_xy	POSx,POSy	; Vai para posi��o do cursor
		
IMPRIME:mov		ah, 02h
		mov		dl, 190		; Coloca AVATAR
		int		21H	
		goto_xy	POSx,POSy	; Vai para posi��o do cursor
		
		mov		al, POSx	; Guarda a posi��o do cursor
		mov		POSxa, al
		mov		al, POSy	; Guarda a posi��o do cursor
		mov 	POSya, al
		
LER_SETA:call 	LE_TECLA
		cmp		ah, 1
		je		ESTEND
		CMP 	AL, 27		; ESCAPE
		JE		FIM
		jmp		LER_SETA
		
ESTEND:	cmp 	al,48h
		jne		BAIXO
		
		dec		POSy
		goto_xy	POSx,POSy	; Vai para nova possi��o
		
		mov 	ah, 08h
		int		10h		
		mov		Car, al		; Guarda o Caracter que est� na posi��o do Cursor
		mov		Cor, ah		; Guarda a cor que est� na posi��o do Cursor
		cmp		al,	88
		je		GAME_OVER_CIMA
		cmp		al, 176
		je		BARREIRA_CIMA
		cmp		al, 177
		je		BARREIRA_CIMA
		cmp		al, 178
		je		BARREIRA_CIMA
		cmp		al, 219
		je		BARREIRA_CIMA
		
		jmp		CICLO

BAIXO:	cmp		al,50h
		jne		ESQUERDA
		
		inc		POSy
		goto_xy	POSx,POSy	; Vai para nova possi��o
		
		mov 	ah, 08h
		int		10h		
		mov		Car, al		; Guarda o Caracter que est� na posi��o do Cursor
		mov		Cor, ah		; Guarda a cor que est� na posi��o do Cursor
		cmp		al,	88
		je		GAME_OVER_BAIXO
		cmp		al, 176
		je		BARREIRA_BAIXO
		cmp		al, 177
		je		BARREIRA_BAIXO
		cmp		al, 178
		je		BARREIRA_BAIXO
		cmp		al, 219
		je		BARREIRA_BAIXO
		
		mov		Car, 32
		
		jmp		CICLO

ESQUERDA:
		cmp		al,4Bh
		jne		DIREITA
		
		dec		POSx
		goto_xy	POSx,POSy	; Vai para nova possi��o
		
		mov 	ah, 08h
		int		10h		
		mov		Car, al		; Guarda o Caracter que est� na posi��o do Cursor
		mov		Cor, ah		; Guarda a cor que est� na posi��o do Cursor
		cmp		al,	88
		je		GAME_OVER_ESQUERDA
		cmp		al, 176
		je		BARREIRA_ESQUERDA
		cmp		al, 177
		je		BARREIRA_ESQUERDA
		cmp		al, 178
		je		BARREIRA_ESQUERDA
		cmp		al, 219
		je		BARREIRA_ESQUERDA
		
		mov		Car, 32
		
		jmp		CICLO

DIREITA:
		cmp		al,4Dh
		jne		LER_SETA
		
		inc		POSx
		goto_xy	POSx,POSy	; Vai para nova possi��o
		 
		mov 	ah, 08h
		int		10h		
		mov		Car, al		; Guarda o Caracter que est� na posi��o do Cursor
		mov		Cor, ah		; Guarda a cor que est� na posi��o do Cursor
		cmp		al,	88
		je		GAME_OVER_DIREITA
		cmp		al,	58
		je		fim
		cmp		al, 176
		je		BARREIRA_DIREITA
		cmp		al, 177
		je		BARREIRA_DIREITA
		cmp		al, 178
		je		BARREIRA_DIREITA
		cmp		al, 219
		je		BARREIRA_DIREITA
		
		mov		Car, 32
		
		jmp		CICLO

BARREIRA_CIMA:
		mov 	ah, 08h
		int		10h		
		mov		Car, al		; Guarda o Caracter que est� na posi��o do Cursor
		mov		Cor, ah		; Guarda a cor que est� na posi��o do Cursor
		
		mov		ah, 02h
		mov		dl, Car		; Repoe caracter guardado
		int		21H
		
		inc		POSy
		goto_xy	POSx,POSy	; Vai para a posi��o anterior do cursor
		mov		ah, 02h
		mov		dl, 190		; Repoe Caracter guardado 
		int		21H
		
		mov		Car, 32
		
		jmp		CICLO
		
BARREIRA_BAIXO:
		mov 	ah, 08h
		int		10h		
		mov		Car, al		; Guarda o Caracter que est� na posi��o do Cursor
		mov		Cor, ah		; Guarda a cor que est� na posi��o do Cursor
		
		mov		ah, 02h
		mov		dl, Car		; Repoe caracter guardado
		int		21H
		
		dec		POSy
		goto_xy	POSx,POSy	; Vai para a posi��o anterior do cursor
		mov		ah, 02h
		mov		dl, 190		; Repoe Caracter guardado 
		int		21H
		
		mov		Car, 32
		
		jmp		CICLO
		
BARREIRA_ESQUERDA:
		mov 	ah, 08h
		int		10h		
		mov		Car, al		; Guarda o Caracter que est� na posi��o do Cursor
		mov		Cor, ah		; Guarda a cor que est� na posi��o do Cursor
		
		mov		ah, 02h
		mov		dl, Car		; Repoe caracter guardado
		int		21H
		
		inc		POSx
		goto_xy	POSx,POSy	; Vai para a posi��o anterior do cursor
		mov		ah, 02h
		mov		dl, 190		; Repoe Caracter guardado 
		int		21H
		
		mov		Car, 32
		
		jmp		CICLO

BARREIRA_DIREITA:
		mov 	ah, 08h
		int		10h		
		mov		Car, al		; Guarda o Caracter que est� na posi��o do Cursor
		mov		Cor, ah		; Guarda a cor que est� na posi��o do Cursor
		
		mov		ah, 02h
		mov		dl, Car		; Repoe caracter guardado
		int		21H
		
		dec		POSx
		goto_xy	POSx,POSy	; Vai para a posi��o anterior do cursor
		mov		ah, 02h
		mov		dl, 190		; Repoe Caracter guardado 
		int		21H
		
		mov		Car, 32
		
		jmp		CICLO
		
GAME_OVER_CIMA:
		mov 	ah, 08h
		int		10h		
		mov		Car, al		; Guarda o Caracter que est� na posi��o do Cursor
		mov		Cor, ah		; Guarda a cor que est� na posi��o do Cursor
		
		inc		POSy
		goto_xy	POSx,POSy
		mov		ah, 02h
		mov		dl, 32
		int		21H	
		
		dec		POSy
		goto_xy	POSx,POSy
		mov		ah, 02h
		mov		dl, 190		; Coloca AVATAR
		int		21H
		
		goto_xy	4, 20
		mov     ah,	09h
        lea     dx,	End_Msg
        int     21h
		
GAME_OVER_BAIXO:
		mov 	ah, 08h
		int		10h		
		mov		Car, al		; Guarda o Caracter que est� na posi��o do Cursor
		mov		Cor, ah		; Guarda a cor que est� na posi��o do Cursor
		
		dec		POSy
		goto_xy	POSx,POSy
		mov		ah, 02h
		mov		dl, 32
		int		21H	
		
		inc		POSy
		goto_xy	POSx,POSy
		mov		ah, 02h
		mov		dl, 190		; Coloca AVATAR
		int		21H
		
		goto_xy	4, 20
		mov     ah,	09h
        lea     dx,	End_Msg
        int     21h
		
GAME_OVER_ESQUERDA:
		inc		POSx
		goto_xy	POSx,POSy
		mov		ah, 02h
		mov		dl, 32
		int		21H	
		
		dec		POSx
		goto_xy	POSx,POSy
		mov		ah, 02h
		mov		dl, 190		; Coloca AVATAR
		int		21H
		
		goto_xy	4, 20
		mov     ah,	09h
        lea     dx,	End_Msg
        int     21h
		
GAME_OVER_DIREITA:
		dec		POSx
		goto_xy	POSx,POSy
		mov		ah, 02h
		mov		dl, 32
		int		21H	
		
		inc		POSx
		goto_xy	POSx,POSy
		mov		ah, 02h
		mov		dl, 190		; Coloca AVATAR
		int		21H
		
		goto_xy	4, 20
		MOSTRA	End_Msg

fim:	
		call	Ler_TEMPO
		
		mov 	ax,	Horas
		mov		bx,	3600
		mul		bx
		add		ax,	dx
		mov		HF,	ax
		
		mov 	ax,	Minutos
		mov		bx,	60
		mul		bx
		add		ax,	dx
		mov		MF,	ax
		
		mov		ax,	Segundos
		mov		SF,	ax
		
		xor		ax,	ax
		xor		dx,	dx
		mov		ax,	HF
		mov		dx,	MF
		add		ax,	dx
		mov		dx,	SF
		add		ax,	dx
		mov		TF,	ax
		
		xor		ax,	ax
		xor		dx,	dx
		mov		ax,	TF
		mov		dx,	TI
		sub		ax,	dx
		mov		TF,	ax
		
		xor		ax,	ax
		xor		dx,	dx
		xor		bx,	bx
		mov 	ax,	TF
		mov 	bx,	3600
		div 	bx
		mov 	bl, 10
		div 	bl
		add 	al, 30h				; Caracter Correspondente �s dezenas
		add		ah,	30h				; Caracter Correspondente �s unidades
		mov 	TEMPO[0],al
		mov 	TEMPO[1],ah
		mov 	TEMPO[2],'H'
		mov 	TEMPO[3],' '
		mov     TEMP[0],al
		mov     TEMP[1],ah
		
		xor		ax,	ax
		xor		dx,	dx
		xor		bx,	bx
		mov 	ax,	TF
		mov 	bx,	60
		div 	bx
		mov 	bl, 10
		div 	bl
		add 	al, 30h				; Caracter Correspondente �s dezenas
		add		ah,	30h				; Caracter Correspondente �s unidades
		mov 	TEMPO[4],al
		mov 	TEMPO[5],ah
		mov 	TEMPO[6],'M'
		mov 	TEMPO[7],' '
		mov     TEMP[2],al
		mov     TEMP[3],ah
		
		xor		ax,	ax
		xor		dx,	dx
		xor		bx,	bx
		mov 	ax,	TF
		mov 	bx,	60
		div 	bx
		mov 	ax,	dx
		MOV 	bl, 10     
		div 	bl
		add 	al, 30h				; Caracter Correspondente �s dezenas
		add		ah,	30h				; Caracter Correspondente �s unidades
		mov 	TEMPO[8],al
		mov 	TEMPO[9],ah
		mov 	TEMPO[10],'S'
		mov 	TEMPO[11],'$'
		mov     TEMP[4],al
		mov     TEMP[5],ah
		mov 	TEMP[6],'$'
		
		
;########################################################################
;########################################################################
		
		goto_xy	9, 21
		MOSTRA	TEMPO
		;MOSTRA	End_Msg ;Repete 2x
		
		jmp test_top_ten
		
		
test_top_ten:
		mov ah, top10[10][00]
		cmp ah, ' '
		je  preenche_top10   
		jne top10_preenchido
		MOSTRA	top10
		
preenche_top10: 
		mov al,tempo
		mov top10[10][00],al
		
		
top10_preenchido:
		jmp preenche_top10_aux
		mov al,temp
		cmp top10_aux,al
		

preenche_top10_aux:
		mov al,top10[10][00]
		mov top10_aux[0],al
		mov al,top10[10][01]
		mov top10_aux[1],al
		mov al,top10[10][04]
		mov top10_aux[2],al
		mov al,top10[10][05]
		mov top10_aux[3],al
		mov al,top10[10][08]
		mov top10_aux[4],al
		mov al,top10[10][09]
		mov top10_aux[5],al
		 		
		
		
sair:
		mov		ah,4CH
		INT		21H
Main	endp
Cseg	ends
end	Main


		

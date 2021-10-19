# -----------------------------------------------------------
# DESC: Calcolo del fattoriale, se %BL < 0 o > 9 ritorna -1, se è ==0 ritorna 1, altrimenti ritorna il fattoriale
# IN: %BL
# OUT: %EAX
fact:			
				# check
				CMP $9, %BL 			# controllo se %BL é maggiore di 9
				JA fact_err
				CMP $0, %BL 			# cotrollo se %BL é minore di 0
				JL fact_err

				PUSH %EBX 				# salvataggio registro
				XOR %EAX, %EAX 			# pulizia registro
				AND $0x000000FF,  %EBX 	# pulizia registro

				MOV %BL, %AL
				JZ fact_is_zero
				JMP fact_loop

	fact_loop:		
				DEC %EBX
				JZ fact_end_loop
				MUL %EBX
				JMP fact_loop
	fact_end_loop:
				POP %EBX 				# ripristino registro allo stato precedente
				JMP fact_end
						
	fact_err:	# gestione eccezioni	
				MOV $-1, %EAX
				JMP fact_end
				
	fact_is_zero:	
				MOV $1, %EAX
				JMP fact_end_loop

	fact_end:	RET

# -----------------------------------------------------------
# DESC: calcola il coeff binomiale, con A>=B e A<10
# IN: %BH (A), %BL (B)
# OUT: %EAX
.DATA

a_fact:			.LONG 0
b_fact:			.LONG 0

.TEXT
binom_coeff:
				CMP %BH, %Bl
				JA binom_coeff_end
				CMP $9, %BH
				JA binom_coeff_end

				PUSH %BX
				PUSH %CX
				PUSH %EDX

				MOV %BH, %CL
				SUB %BL, %CL		# (A-B) in %CL
				
				CALL fact			# fact(B) in %EAX
				MOV %EAX, b_fact

				MOV %BH, %BL
				CALL fact			# fact(A) in %EAX
				MOV %EAX, a_fact

				MOV %CL, %Bl
				CALL fact			# fact(A-B) in %EAX
				# MOV %EAX, ab_fact

				MULL b_fact
				XCHG %EAX, a_fact
				DIVL a_fact

				POP %EDX
				POP %CX
				POP %BX

	binom_coeff_end:
				RET

# -----------------------------------------------------------
# DESC: Trova il minimo e il massimo tra 2 numeri
# IN: %EAX, %EBX
# OUT: %EAX (min), %EBX (max)
min_max:			
				CMP %EAX, %EBX
				JG min_max_end
				XCHG %EAX, %EBX
	min_max_end:	
				RET

# -----------------------------------------------------------
# DESC: Calcola il MCD tra 2 numeri (%AX e %BX)
# IN: %AX, %BX
# OUT: %AX

mcd:		
				PUSH %DX
	mcd_loop:
				CMP $0, %BX
				JE mcd_end
				XOR %DX, %DX
				DIV %BX
				MOV %BX, %AX
				MOV %DX, %BX
				JMP mcd_loop
	mcd_end:	
				POP %DX
				RET

# -----------------------------------------------------------
# DESC: Conta numero caratteri di una stringa
# IN: %ESI (puntatore)
# OUT: %ECX
strlen:				
				XOR %ECX, %ECX
	strlen_l1:	
				CMPB $0, (%ESI,%ECX,1)				# controllo fine stringa
				JE strlen_l1e
				INC %ECX
				JMP strlen_l1
	strlen_l1e:		
				RET

# -----------------------------------------------------------
# DESC: Ritorna il numero minimo di caratteri di 2 stringhe
# IN: %ESI, %EDI
# OUT: %ECX
strlen_min:		
				PUSH %EAX
				PUSH %EBX	
				CALL strlen # lunghezza prima stringa
				MOV %ECX, %EAX
				XCHG %ESI, %EDI
				CALL strlen # lunghezza seconda stringa
				MOV %ECX, %EBX
				XCHG %ESI, %EDI
				CALL min_max 
				MOV %EAX, %ECX # lunghezza minore
				POP %EBX	
				POP %EAX
				RET

# -----------------------------------------------------------
# DESC: copia la stringa sorgente (%ESI) nella stringa destinazione (%EDI)
# IN: %ESI (sorgente), %EDI (destinazione)
# OUT: NULL
strcopy:		
				PUSH %ECX
				CALL strlen_min
				CLD
				REP MOVSB # copia stringa sorgente nella stringa destinazione
				POP %ECX
				RET

# -----------------------------------------------------------
# DESC: Compara 2 stringhe, ritorna 0 se le stringhe sono uguali, 1 se la prima è successiva alla seconda, -1 altrimenti.
# IN: %ESI, %EDI
# OUT: %AL
strcomp:		
				PUSH %BX
				PUSH %ECX
				PUSH %ESI
				PUSH %EDI
				CALL strlen_min
				INC %ECX	# per confrontare '\0'
				CLD

	strcomp_l:
				# %BH = *(%ESI), %BL = *(%EDI)
				LODSB
				MOV %AL, %BH
				XCHG %ESI, %EDI

				LODSB
				MOV %AL, %BL
				XCHG %ESI, %EDI

				CMP %BL, %BH
				JA strcomp_A
				JB strcomp_B

				LOOP strcomp_l

				XOR %AL, %AL
				JMP strcomp_end
	strcomp_A:
				MOV $1, %AL
				JMP strcomp_end
	strcomp_B:
				MOV $-1, %AL
				JMP strcomp_end
	strcomp_end:
				POP %EDI
				POP %ESI
				POP %ECX
				POP %BX
				RET

# -----------------------------------------------------------
# DESC: Trova il primo/ carattere (passato tramite %AL) nella stringa (puntata da %ESI), se viene trovato viene poi puntato da %EDI altrimente %EDI vale zero
# IN: %ESI, %AL
# OUT: %EDI
strrchr: # prima occorenza
				PUSH %ECX
				PUSH %ESI
				STD
				CALL strlen
				ADD %ECX, %ESI
				JMP strchr_s
strchr:	# ultima occorenza
				PUSH %ECX
				PUSH %ESI
				CLD
				JMP strchr_s
	strchr_s:
				PUSH %AX
				MOV %AL, %AH
				CALL strlen
	strchr_l:	
				MOV %ESI, %EDI
				LODSB
				CMP %AL, %AH
				JE strchr_end
				LOOP strchr_l
				XOR %EDI, %EDI
	strchr_end:
				POP %AX
				POP %ESI
				POP %ECX
				RET

# -----------------------------------------------------------
# DESC: Stampa una stringa di caratteri
# IN: %ESI (puntatore)
# OUT: NULL
print:
				PUSH %EDX
				PUSH %ECX
				PUSH %EBX
				PUSH %EAX
				CALL strlen			# conteggio caratteri da stampare
				MOV %ECX, %EDX
				MOV $4, %EAX		# procedura sys_write
				MOV $1, %EBX		# settaggio fd a stdout
				MOV %ESI, %ECX		# indirizzo del buffer
				INT $0x80			# syscall
				POP %EAX
				POP %EBX
				POP %ECX
				POP %EDX
				RET

# -----------------------------------------------------------
# DESC: Converte un numero intero in stringa di caratteri, il ritorno è l'array puntato da %EDI
# IN: %EAX
# OUT: %EDI
.DATA
int2str_msg:	.FILL 10, 4, 0
int2str_gap:	.BYTE 48
int2str_tmp:	.LONG 1000000000
.TEXT
int2str:
				PUSH %EBX
				PUSH %ECX
				PUSH %EDX
				LEA int2str_msg, %EDI
				XOR %ECX, %ECX
				MOV %EAX, %EBX
				SHL %EBX
				JC int2str_n
				JMP int2str_p
	int2str_n:
				MOVB $'-', (%EDI,%ECX,1)
				INC %ECX
				NEG %EAX
	int2str_p:		
				MOV %EAX, %EBX
	int2str_l:
				MOV %EBX, %EAX

				CMP int2str_tmp, %EAX
				JB int2str_d

				DIVL int2str_tmp
				# ADD %EDX, %EBX
				MOV %AL, (%EDI,%ECX,1)
				MOV int2str_gap, %DL
				ADD %DL, (%EDI,%ECX,1)
				INC %ECX

				MULL int2str_tmp
				SUB %EAX, %EBX
	int2str_d:
				MOV int2str_tmp, %EAX
				MOVL $10, int2str_tmp
				DIVL int2str_tmp
				MOV %EAX, int2str_tmp
				CMP $0, int2str_tmp
				JNE int2str_l

				POP %EDX
				POP %ECX
				POP %EBX

				RET
# fattoriale -----------------------------------------------------------
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

fact_end:		RET

# coefficiente binomiale -----------------------------------------------------------
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

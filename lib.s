# DESC: Calcolo del fattoriale
# IN: BL
# OUT: EAX
fact:			
				# check
				CMP $9, %BL 			# controllo se %BL é maggiore di 9
				JA fact_err
				CMP $0, %BL 			# cotrollo se %BL é minore di 0
				JB fact_err

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
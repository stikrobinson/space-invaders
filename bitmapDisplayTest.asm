 .data
	displayAddress:	.word 0x10008000

.text
   li $t2, 0xffff0000  #direccion de memoria donde se almacena si la tecla fue presionada
   li $t3, 0xffff0004  #direccion de memoria donde se almacena la tecla presionada
   lw $t0, displayAddress #cargar la direccion de memoria donde se guarda el primer pixel
   li $t1, 0xFF0000 #color rojo
   li $t9, 0x00000 #color negro
   sw $t1, 0($t0) #pintar el primer pixel de rojo
   
   #variables de posición 
   li $s3, 0 #profundidad
   li $s4, 0 #ancho

loop:
	lw $s0, 0($t2)   #conocer si una tecla fue presionada
	beq $s0, $zero, loop #si no fue presionada repetir el loop
	lw $s2, 0($t3) #cargar la tecla presionada en ascii
	beq $s2, 0x00000073, letraS #si la tecla fue s, ir a las instrucciones correspondientes
	beq $s2, 0x00000077, letraW #si la tecla fue w, ir a las instrucciones correspondientes
	beq $s2, 0x00000061, letraA #si la tecla fue a, ir a las instrucciones correspondientes
	bne $s2, 0x00000064, loop #si la tecla no fue d, ni las anteriores, repetir el loop
	beq $s4, 31, loop #si ya está muy a la derecha, no puede moverse más
	sw $t9, 0($t0) #pintar de negro el pixel donde estaba
	addi $s4, $s4, 1 #aumentar anchura en 1
	addi $t0, $t0, 4 #aumentar en 4 el offset de la direccion del pixel
	sw $t1, 0($t0) #pintar el siguiente pixel de rojo
	j loop #repetir

letraS:
	beq $s3, 31, loop #si ya está muy abajo, no puede moverse más
	sw $t9, 0($t0) #pintar de negro el pixel donde estaba
	addi $t0, $t0, 128 #aumentar en 128 el offset de la direccion del pixel
	addi $s3, $s3, 1 #aumentar profundidad en 1
	sw $t1, 0($t0) #pintar el siguiente pixel de rojo
	j loop #repetir

letraW:
	beq $s3, 0, loop #si ya está muy arriba, no puede moverse más
	sw $t9, 0($t0) #pintar de negro el pixel donde estaba
	addi $t0, $t0, -128 #disminuye en 128 el offset de la direccion del pixel
	addi $s3, $s3, -1 #disminuir profundidad en 1
	sw $t1, 0($t0) #pintar el siguiente pixel de rojo
	j loop #repetir

letraA:
	beq $s4, 0, loop #si ya está muy a la izquierda, no puede moverse más
	sw $t9, 0($t0) #pintar de negro el pixel donde estaba
	addi $t0, $t0, -4 #aumentar en 128 el offset de la direccion del pixel
	addi $s4, $s4, -1 #disminuir anchura en 1
	sw $t1, 0($t0) #pintar el siguiente pixel de rojo
	j loop #repetir
	

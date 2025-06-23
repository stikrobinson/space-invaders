.data
	displayAddress:	.word 0x10008000

.text
   li $t2, 0xffff0000  #direccion de memoria donde se almacena si la tecla fue presionada
   li $t3, 0xffff0004  #direccion de memoria donde se almacena la tecla presionada
   lw $t0, displayAddress #cargar la direccion de memoria donde se guarda el primer pixel
   li $t1, 0x00FF00 #color verde
   li $t4, 0x000000 #color negro
   addi $t5, $t0, 14336 #direccion de spawneo de la nave
   
   li $s4, 0 #posicion de la nave (en el eje x)
   
   #Prueba de la creacion de alien1 y 2
   move $a0, $t0
   move $a1, $t1
   jal pintarAlien1 
   
   addi $t0,$t0,52
   move $a0, $t0
   move $a1, $t1
   jal pintarAlien2 
   addi $t0,$t0,-52
   
   
   move $a0, $t5
   move $a1, $t1
 
   jal pintarNave
  
 juego:
	lw $s0, 0($t2)   #conocer si una tecla fue presionada
	beq $s0, $zero, juego #si no fue presionada repetir el loop
	lw $s2, 0($t3) #cargar la tecla presionada en ascii
	beq $s2, 0x00000061, letraA #si la tecla fue a, ir a las instrucciones correspondientes
	beq $s2, 0x00000020, espacio #si la tecla fue espacio, ir a las instrucciones correspondientes
	bne $s2, 0x00000064, juego #si la tecla no fue d, ni las anteriores, repetir el loop
	beq $s4, 53, juego #si ya está muy a la derecha, no puede moverse más
	addi $s4, $s4, 1 #aumentar posicion x en 10
	#llamado funcion pintar (posicionActual,negro)
	move $a0, $t5
	move $a1, $t4 #guardar negro como argumento
	jal pintarNave
	addi $t5, $t5, 4 #aumentar en 4 el offset de la direccion del pixel
	move $a0, $t5
	#llamado funcion pintar (posicionActual,verde)
	move $a1, $t1 #guardar verde como argumento
	jal pintarNave
	j juego #repetir

letraA:
	beq $s4, 0, juego #si ya está muy a la izquierda, no puede moverse más
	#llamado funcion pintar (posicionActual,negro)
	move $a0, $t5
	move $a1, $t4 #guardar negro como argumento
	jal pintarNave
	addi $t5, $t5, -4 #disminuir en 4 el offset de la direccion del pixel
	addi $s4, $s4, -1 #disminuir posicion x en 1
	#llamado funcion pintar (posicionActual,verde) 
	move $a0, $t5
	move $a1, $t1 #guardar verde como argumento
	jal pintarNave
	j juego #repetir

espacio:
	 move $a0, $t5 #direccion de spawneo de naves
	 jal disparo
	 j juego

#funciones  

disparo:
#a0 = direccion de inicio  
	li $t7, 0xFFFFFF #color blanco  
	addi $t6, $a0, 20 #centra el disparo de la nave
	addi $t8, $t6, -2560
loop:
	beq $t6, $t8, exit
	addi $t6, $t6, -256

	sw $t7, 0($t6)

	j loop

exit:
	jr $ra

pintarNave: 
#a0 = direccion de inicio
#a1 = color
#altura 0 → +256*0 = 0
sw $a1, 20($a0)

#altura 1 → +256*1 = 256
sw $a1, 272($a0)
sw $a1, 276($a0) 
sw $a1, 280($a0)

#altura 2 → +256*2 = 512
sw $a1, 528($a0)
sw $a1, 532($a0)
sw $a1, 536($a0)

#altura 3 → +256*3 = 768
sw $a1, 772($a0)
sw $a1, 776($a0)
sw $a1, 780($a0)
sw $a1, 784($a0)
sw $a1, 788($a0)
sw $a1, 792($a0)
sw $a1, 796($a0)
sw $a1, 800($a0)
sw $a1, 804($a0)

#altura 4 → +256*4 = 1024
sw $a1, 1024($a0)
sw $a1, 1028($a0)
sw $a1, 1032($a0)
sw $a1, 1036($a0)
sw $a1, 1040($a0)
sw $a1, 1044($a0)
sw $a1, 1048($a0)
sw $a1, 1052($a0)
sw $a1, 1056($a0)
sw $a1, 1060($a0)
sw $a1, 1064($a0)

#altura 5 → +256*5 = 1280
sw $a1, 1280($a0)
sw $a1, 1284($a0)
sw $a1, 1288($a0)
sw $a1, 1292($a0)
sw $a1, 1296($a0)
sw $a1, 1300($a0)
sw $a1, 1304($a0)
sw $a1, 1308($a0)
sw $a1, 1312($a0)
sw $a1, 1316($a0)
sw $a1, 1320($a0)

#altura 6 → +256*6 = 1536
sw $a1, 1536($a0)
sw $a1, 1540($a0)
sw $a1, 1544($a0)
sw $a1, 1548($a0)
sw $a1, 1552($a0)
sw $a1, 1556($a0)
sw $a1, 1560($a0)
sw $a1, 1564($a0)
sw $a1, 1568($a0)
sw $a1, 1572($a0)
sw $a1, 1576($a0)

jr $ra
       
#llamada a sleep
   #li $a0, 2000
   #li $v0, 32
   
   #syscall 
   
  
pintarAlien1: 
#a0 = direccion de inicio
#a1 = color
#altura 0 → +256*0 = 0
sw $a1, 16($a0)
sw $a1, 20($a0)
sw $a1, 24($a0)
sw $a1, 28($a0)

#altura 1 → +256*1 = 256
sw $a1, 260($a0)
sw $a1, 264($a0) 
sw $a1, 268($a0)
sw $a1, 272($a0)
sw $a1, 276($a0)
sw $a1, 280($a0)
sw $a1, 284($a0)
sw $a1, 288($a0)
sw $a1, 292($a0)
sw $a1, 296($a0)

#altura 2 → +256*2 = 512
sw $a1, 512($a0)
sw $a1, 516($a0)
sw $a1, 520($a0)
sw $a1, 524($a0)
sw $a1, 528($a0)
sw $a1, 532($a0)
sw $a1, 536($a0)
sw $a1, 540($a0)
sw $a1, 544($a0)
sw $a1, 548($a0)
sw $a1, 552($a0)
sw $a1, 556($a0)


#altura 3 → +256*3 = 768
sw $a1, 768($a0)
sw $a1, 772($a0)
sw $a1, 776($a0)
sw $a1, 788($a0)
sw $a1, 792($a0)
sw $a1, 804($a0)
sw $a1, 808($a0)
sw $a1, 812($a0)

#altura 4 → +256*4 = 1024
sw $a1, 1024($a0)
sw $a1, 1028($a0)
sw $a1, 1032($a0)
sw $a1, 1036($a0)
sw $a1, 1040($a0)
sw $a1, 1044($a0)
sw $a1, 1048($a0)
sw $a1, 1052($a0)
sw $a1, 1056($a0)
sw $a1, 1060($a0)
sw $a1, 1064($a0)
sw $a1, 1068($a0)

#altura 5 → +256*5 = 1280
sw $a1, 1292($a0)
sw $a1, 1296($a0)
sw $a1, 1308($a0)
sw $a1, 1312($a0)

#altura 6 → +256*6 = 1536
sw $a1, 1544($a0)
sw $a1, 1548($a0)
sw $a1, 1556($a0)
sw $a1, 1560($a0)
sw $a1, 1568($a0)
sw $a1, 1572($a0)

#altura 7 → +256*7 = 1792
sw $a1, 1792($a0)
sw $a1, 1796($a0)
sw $a1, 1832($a0)
sw $a1, 1836($a0)

jr $ra

pintarAlien2: 
#a0 = dirección de inicio
#a1 = color

#altura 0 → +256*0 = 0
sw $a1, 8($a0)
sw $a1, 32($a0)

#altura 1 → +256*1 = 256
sw $a1, 268($a0)
sw $a1, 284($a0)

#altura 2 → +256*2 = 512
sw $a1, 520($a0)
sw $a1, 524($a0)
sw $a1, 528($a0)
sw $a1, 532($a0)
sw $a1, 536($a0)
sw $a1, 540($a0)
sw $a1, 544($a0)


#altura 3 → +256*3 = 768
sw $a1, 772($a0)
sw $a1, 776($a0)
sw $a1, 784($a0)
sw $a1, 788($a0)
sw $a1, 792($a0)
sw $a1, 800($a0)
sw $a1, 804($a0)

#altura 4 → +256*4 = 1024
sw $a1, 1024($a0)
sw $a1, 1028($a0)
sw $a1, 1032($a0)
sw $a1, 1036($a0)
sw $a1, 1040($a0)
sw $a1, 1044($a0)
sw $a1, 1048($a0)
sw $a1, 1052($a0)
sw $a1, 1056($a0)
sw $a1, 1060($a0)
sw $a1, 1064($a0)

#altura 5 → +256*5 = 1280
sw $a1, 1280($a0)
sw $a1, 1288($a0)
sw $a1, 1292($a0)
sw $a1, 1296($a0)
sw $a1, 1300($a0)
sw $a1, 1304($a0)
sw $a1, 1308($a0)
sw $a1, 1312($a0)
sw $a1, 1320($a0)


#altura 6 → +256*6 = 1536
sw $a1, 1536($a0)
sw $a1, 1544($a0)
sw $a1, 1568($a0)
sw $a1, 1576($a0)

#altura 7 → +256*7 = 1792
sw $a1, 1804($a0)
sw $a1, 1808($a0)
sw $a1, 1816($a0)
sw $a1, 1820($a0)

jr $ra


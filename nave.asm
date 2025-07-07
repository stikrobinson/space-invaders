.data
    final: .asciiz "Fin de la partida!\n"   

    coordenadasX: .word 0, 14, 28, 42, 0, 14, 28, 42, 0, 14, 28, 42, 0, 14, 28, 42
    coordenadasY: .word 0, 0, 0, 0, 10, 10, 10, 10, 20, 20, 20, 20, 30, 30, 30, 30
    estadoAliens: .word 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    
    coordenadasDisparoAlien: .word 0, 0
    
    displayAddress:         .word 0x10008000

    addrTeclaPresionada:    .word 0xffff0000   # dirección de memoria donde se almacena si la tecla fue presionada
    addrCodigoTecla:        .word 0xffff0004   # dirección de memoria donde se almacena la tecla presionada (ASCII)

    colorVerde:             .word 0x00FF00     # color verde
    colorNegro:             .word 0x000000     # color negro
    colorBlanco:            .word 0xFFFFFF     # color blanco
    colorRojo: 	            .word 0xFF0000     # color rojo

.text
# seguras para manejar el estado del juego
    lw $t0, displayAddress  
    li $s0, 0     # $s0 = posición de la nave (en el eje x)
    li $s1, 55     # $s1 = altura del disparo (si vale 55 es porque no está disparando)
    li $s2, 0     # $s2= dirección del disparo
    addi $s3, $t0, 14336         # $s3 = dirección de spawneo de la nave
    li $s4, 1     # $s4 = dirección del movimiento de los aliens (1=derecha, 0=izquierda)
	
    lw $a0, colorVerde
    jal pintarAliens

dibujarNave: 
    move $a0, $s3              # posición actual de la nave
    lw $a1, colorVerde             # color verde 
    jal pintarNave

juego:
   jal disparoAlien
   
   lw $a0, colorRojo
   jal pintarDisparoAlien
   
   jal moverDisparoAlien

    move $a0, $s2              # dirección del disparo
    move $a1, $s1              # ¿está disparando? 
    
    jal actualizarDisparo
    move $s2, $v0
    jal verificarColisionDisparo
    
    jal verificarColisionDisparoNave
    
    li $a0, 30000
    jal retardo
    
   beq $s4, 0, moverIzquierdaBranch
   jal moverAliensDerecha
   j cambiarDisparo
 
   moverIzquierdaBranch:
   jal moverAliensIzquierda
  
 cambiarDisparo:
    beq $s2, $zero, cambiar
    addi $s1, $s1, -1           # aumentar estado de disparo

subjuego: 
    lw $t2, addrTeclaPresionada  # $t2 = dirección de memoria donde se almacena si la tecla fue presionada
    lw $t5, 0($t2)             # conocer si una tecla fue presionada
    beq $t5, $zero, juego      # si no fue presionada, repetir el loop

    lw $t3, addrCodigoTecla      # $t3 = dirección donde se almacena la tecla presionada (ASCII)
    lw $t6, 0($t3)             # cargar la tecla presionada en ASCII
    beq $t6, 0x00000061, letraA    # si la tecla fue 'a', ir a instrucciones correspondientes
    beq $t6, 0x00000020, espacio   # si la tecla fue espacio, ir a instrucciones correspondientes
    bne $t6, 0x00000064, juego     # si la tecla no fue 'd', ni las anteriores, repetir el loop
    beq $s0, 53, juego             # si ya está muy a la derecha, no puede moverse más

    addi $s0, $s0, 1               # aumentar posición x en 1

    # llamado función pintar (posiciónActual, negro)
    move $a0, $s3
    lw $a1, colorNegro                # guardar negro como argumento
    jal pintarNave

    addi $s3, $s3, 4               # aumentar en 4 el offset de la dirección del pixel
    move $a0, $s3

    # llamado función pintar (posiciónActual, verde)
    lw $a1, colorVerde                 # guardar verde como argumento
    jal pintarNave
    j juego                        # repetir

cambiar:    
    li $s1, 55                      # reiniciar estado de disparo
    j subjuego

letraA:
    beq $s0, 0, juego              # si ya está muy a la izquierda, no puede moverse más

    # llamado función pintar (posiciónActual, negro)
    move $a0, $s3
    lw $a1, colorNegro                 # guardar negro como argumento
    jal pintarNave

    addi $s3, $s3, -4              # disminuir en 4 el offset de la dirección del pixel
    addi $s0, $s0, -1              # disminuir posición x en 1

    # llamado función pintar (posiciónActual, verde)
    move $a0, $s3
    lw $a1, colorVerde                 # guardar verde como argumento
    jal pintarNave
    j juego                        # repetir

espacio:
    bne $s1, 55, juego          # si ya está disparando, ignorar

    move $a0, $s3                  # dirección de spawneo de la nave
    move $a1, $s1
    jal disparo
    move $s2, $v0                  # dirección que maneja el disparo
    li $s1, 54                      # activar estado de disparo
    j juego

#############
# funciones #
#############

disparo:
    lw $t7, colorBlanco            # color blanco  
    addi $t6, $a0, -236            # centrar el disparo de la nave
    sw $t7, 0($t6)
    sw $t7, -256($t6)
    move $v0, $t6
    jr $ra

actualizarDisparo:
    beq $a0, $zero, alternative
    beq $a1, $zero, reiniciar

    lw $t7, colorBlanco            # color blanco
    lw $t8, colorNegro             # color negro
    
    sw $t8, 0($a0)
    addi $t6, $a0, -256            # subir el disparo de la nave
    sw $t7, -256($t6)

    #li $a0, 5
    #li $v0, 32
    #syscall
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $a0, 15000
    jal retardo
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    move $v0, $t6
    jr $ra
    
reiniciar:
    lw $t4, colorNegro
    sw $t4, 0($s2)
    sw $t4, -256($s2)

alternative:
    li $v0, 0
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

retardo:
#a0: numero de iteraciones (retardo)
li $t9, 0 
bucle:
bge $t9, $a0, salida # Si alcanzamos el límite, realizamos una acción
addi $t9, $t9, 1
j bucle

salida:
jr $ra

pintarAliens:
   #a0: color
   lw $t0, displayAddress 
   la $t1, coordenadasX
   la $t2, coordenadasY
   li $t3, 0
   la $t9, estadoAliens
   
    move $t8, $a0
    move $a1, $t8

lazo:    
    lw $t4, 0($t1)
    lw $t5, 0($t2)

    sll $t4, $t4, 2
    sll $t5, $t5, 8
    
    add $t6, $t4, $t5
    add $t6, $t6, $t0
    
    li $t7, 4
    div $t3, $t7
    mflo $t8 
    
    lw $t7, 0($t9)
    
    beq $t7, 0, skip
    
    move $a0, $t6
    
    beq $t8, 1, pintarFilaPar
    beq $t8, 3, pintarFilaPar
    
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    jal pintarAlien1
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    addi $t1, $t1, 4
    addi $t2, $t2, 4
    addi $t9, $t9, 4
    
    beq $t3, 15, salidaPintarAliens
    
    addi $t3, $t3, 1
    
    j lazo
    
pintarFilaPar:
    
    move $a0, $t6
    
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal pintarAlien2
    lw $ra, 0($sp)
    addi $sp, $sp, 4
 
skip:
    addi $t1, $t1, 4
    addi $t2, $t2, 4
    addi $t9, $t9, 4
    
    beq $t3, 15, salidaPintarAliens
    
    addi $t3, $t3, 1
    
    j lazo

salidaPintarAliens: 
    jr $ra

moverAliensDerecha:
 
 lw $a0, colorNegro
 addi $sp, $sp, -4
 sw $ra, 0($sp)
 jal pintarAliens
 lw $ra, 0($sp)
 addi $sp, $sp, 4
 
 li $t0, 0
 la $t2, coordenadasX
 
 addi $sp, $sp, -16
 sw $ra, 0($sp)
 sw $t0, 4($sp)
 sw $t2, 8($sp)
 sw $t4, 12($sp)
 jal maximo
 lw $ra, 0($sp)
 lw $t0, 4($sp)
 lw $t2, 8($sp)
 lw $t4, 12($sp)
 addi $sp, $sp, 16
 
 beq $v0, 52, cambiarDireccionIzquierda 
 
moverDerecha:
 
 lw $t4, 0($t2)
 
 addi $t4, $t4, 1
 sw $t4, 0($t2)
 addi $t2, $t2, 4
  
 beq $t0, 15, salidaMoverDerecha
 addi $t0, $t0, 1
 
 j moverDerecha

cambiarDireccionIzquierda:
  li $s4, 0
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  jal bajarAliens
  lw $ra, 0($sp)
  addi $sp, $sp, 4

salidaMoverDerecha:
  lw $a0, colorVerde
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  jal pintarAliens
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  
  jr $ra
 
maximo:
 la $t0, coordenadasX
 la $t3, estadoAliens
 li $t2, 0
 li $t5, 0

buscarMaximo:
 
 lw $t1, 0($t0)
 lw $t4, 0($t3)
 
 beq $t4, 0, saltarBuscarMaximo
 bgt $t5, $t1, saltarBuscarMaximo
 
 move $t5, $t1

saltarBuscarMaximo:

 addi $t0, $t0, 4
 addi $t3, $t3, 4

 beq $t2, 15, salidaBuscarMaximo
 addi $t2, $t2, 1
 j buscarMaximo

salidaBuscarMaximo:
 move $v0, $t5
 
 jr $ra
 
moverAliensIzquierda:
 
 lw $a0, colorNegro
 addi $sp, $sp, -4
 sw $ra, 0($sp)
 jal pintarAliens
 lw $ra, 0($sp)
 addi $sp, $sp, 4
 
 li $t0, 0
 la $t2, coordenadasX
 
 addi $sp, $sp, -16
 sw $ra, 0($sp)
 sw $t0, 4($sp)
 sw $t2, 8($sp)
 sw $t4, 12($sp)
 jal minimo
 lw $ra, 0($sp)
 lw $t0, 4($sp)
 lw $t2, 8($sp)
 lw $t4, 12($sp)
 addi $sp, $sp, 16
 
 beq $v0, 0, cambiarDireccionDerecha
 
moverIzquierda:

 lw $t4, 0($t2)
 
 addi $t4, $t4, -1
 sw $t4, 0($t2)
 addi $t2, $t2, 4
 
 beq $t0, 15, salidaMoverIzquierda
 addi $t0, $t0, 1
 
 j moverIzquierda

cambiarDireccionDerecha:
  li $s4, 1
  
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  jal bajarAliens
  lw $ra, 0($sp)
  addi $sp, $sp, 4

salidaMoverIzquierda:
  
  lw $a0, colorVerde
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  jal pintarAliens
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  
  jr $ra 
 
minimo:
 la $t0, coordenadasX
 la $t3, estadoAliens
 li $t2, 0
 li $t5, 100

buscarMinimo:
 
 lw $t1, 0($t0)
 lw $t4, 0($t3)
 
 beq $t4, 0, saltarBuscarMinimo
 bgt $t1, $t5, saltarBuscarMinimo
 
 move $t5, $t1

saltarBuscarMinimo:

 addi $t0, $t0, 4
 addi $t3, $t3, 4

 beq $t2, 15, salidaBuscarMinimo
 addi $t2, $t2, 1
 j buscarMinimo

salidaBuscarMinimo:
 move $v0, $t5
 
 jr $ra
 
maximoY:
 la $t0, coordenadasY
 la $t3, estadoAliens
 li $t2, 0
 li $t5, 0

buscarMaximoY:
 
 lw $t1, 0($t0)
 lw $t4, 0($t3)
 
 beq $t4, 0, saltarBuscarMaximoY
 bgt $t5, $t1, saltarBuscarMaximoY
 
 move $t5, $t1

saltarBuscarMaximoY:

 addi $t0, $t0, 4
 addi $t3, $t3, 4

 beq $t2, 15, salidaBuscarMaximoY
 addi $t2, $t2, 1
 j buscarMaximoY

salidaBuscarMaximoY:
 move $v0, $t5
 
 jr $ra
 
bajarAliens:
 
  lw $a0, colorNegro
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  jal pintarAliens
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  jal maximoY
  lw $ra, 0($sp)
  addi $sp, $sp, 4
 
  li $t0, 0
  la $t2, coordenadasY
 
  beq $v0, 48, limiteY

bucleBajarAliens:

 lw $t4, 0($t2)
 
 addi $t4, $t4, 1
 sw $t4, 0($t2)
 addi $t2, $t2, 4
  
 beq $t0, 15, salidaBajarAliens
 addi $t0, $t0, 1
 
 j bucleBajarAliens
 
salidaBajarAliens:
  lw $a0, colorVerde
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  jal pintarAliens
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  
  jr $ra 
 
limiteY:
   li $v0, 4           
   la $a0, final     
   syscall 
   
   li $v0, 10     # Código de syscall para terminar el programa
   syscall        # Llamada al sistema
 
verificarColisionDisparo:
   lw $t0, displayAddress
   la $t1, coordenadasX
   la $t2, coordenadasY
   li $t3, 0
   la $t9, estadoAliens

lazoVerificarColision:    
    lw $t4, 0($t1)
    lw $t5, 0($t2)
    lw $t8, 0($t9)
    
    beq $t8, 0, pasarVerificacion

    li $t7, 4
    div $t3, $t7
    mflo $t8
    
    beq $t8, 1, verificarFilaPar
    beq $t8, 3, verificarFilaPar
    
    lw $t6, displayAddress
    
    #verificacion en eje X
    sub $t6, $s2, $t6
    sll $t5, $s1, 8
    sub $t5, $t6, $t5
    srl $t5, $t5, 2
    
    slt $t8, $t4, $t5
    beq $t8, 0, pasarVerificacion
    
    addi $t4, $t4, 10
    
    slt $t8, $t5, $t4
    beq $t8, 0, pasarVerificacion
    
    #verificacion en eje Y
    lw $t5, 0($t2)
    
    slt $t8, $t5, $s1
    beq $t8, 0, pasarVerificacion
    
    addi $t5, $t5, 9
    slt $t8, $s1, $t5
    beq $t8, 0, pasarVerificacion
    
    sw $zero, 0($t9)
    
    li $s1, 1
    
    lw $t4, colorNegro
    
    sw $t4, 0($s2)
    sw $t4, -256($s2)
    
    lw $t4, 0($t1)
    lw $t5, 0($t2)

    sll $t4, $t4, 2
    sll $t5, $t5, 8
    
    add $t6, $t4, $t5
    add $t6, $t6, $t0
    
    move $a0, $t6
    
    lw $a1, colorNegro
    
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal pintarAlien1
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    j salidaVerificacion
    
verificarFilaPar:
    
    lw $t6, displayAddress
    
    #verificacion en eje X
    
    sub $t6, $s2, $t6
    sll $t5, $s1, 8
    sub $t5, $t6, $t5
    srl $t5, $t5, 2
    
    slt $t8, $t4, $t5
    beq $t8, 0, pasarVerificacion
    
    addi $t4, $t4, 11
    
    slt $t8, $t5, $t4
    beq $t8, 0, pasarVerificacion
    
    #verificacion en eje Y
    lw $t5, 0($t2)
    
    slt $t8, $t5, $s1
    beq $t8, 0, pasarVerificacion
    
    addi $t5, $t5, 9
    slt $t8, $s1, $t5
    beq $t8, 0, pasarVerificacion
    
    sw $zero, 0($t9)
    
    li $s1, 1
    
    lw $t4, colorNegro
    
    sw $t4, 0($s2)
    sw $t4, -256($s2)
    
    lw $t4, 0($t1)
    lw $t5, 0($t2)

    sll $t4, $t4, 2
    sll $t5, $t5, 8
    
    add $t6, $t4, $t5
    add $t6, $t6, $t0
    
    move $a0, $t6
    
    lw $a1, colorNegro
    
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal pintarAlien2
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    j salidaVerificacion
    
pasarVerificacion:

    addi $t1, $t1, 4
    addi $t2, $t2, 4
    addi $t9, $t9, 4
    
    beq $t3, 15, salidaVerificacion
    
    addi $t3, $t3, 1
    
    j lazoVerificarColision
  

salidaVerificacion: 
    jr $ra
  
disparoAlien:
   la $t0, coordenadasDisparoAlien
   lw $t1, 4($t0) # y de coordenada
   la $t2, coordenadasX
   la $t3, coordenadasY
   la $t4, estadoAliens
   
   #verificar si bay un disparo de Alien 
   bne $t1, 0, salidaDisparoAlien
   
   li $t5, 15
   
   #itere 
bucleDeterminarAlien:
   sll $t1, $t5, 2
   add $t6, $t1, $t2 
   add $t7, $t1, $t3 
   add $t8, $t1, $t4
   
   lw $t9, 0($t8)
   beq $t9, $zero, repetirBucleDeterminarAlien
   
   lw $t1, 0($t6)
   
   addi $t1, $t1, 5
   
   sw $t1, 0($t0)
   
   lw $t1, 0($t7)
   
   addi $t1, $t1, 8
   
   sw $t1, 4($t0)
   
   j salidaDisparoAlien
   
repetirBucleDeterminarAlien:
   
   beq $t5, 0, salidaDisparoAlien
   addi $t5, $t5, -1
   
   j bucleDeterminarAlien
   
salidaDisparoAlien:
  jr $ra
   
   
pintarDisparoAlien:
  #a0: color del disparo
   li $t3, 0
   la $t0, coordenadasDisparoAlien
   lw $t1, 4($t0) # y de coordenada
   lw $t2, 0($t0) # x de coordenada
   
   #verificar si bay un disparo de Alien 
   beq $t1, 0, salidaPintarDisparoAlien
   beq $t1, 63, reestablecerDisparoAlien
   
   sll $t2, $t2, 2
   sll $t1, $t1, 8
   
   add $t3, $t2, $t1
   
   lw $t4, displayAddress
   add $t3, $t3, $t4
   
   sw $a0, 0($t3)
   sw $a0, 256($t3)
   
   j salidaPintarDisparoAlien
   
reestablecerDisparoAlien:
   sw $zero, 4($t0)

salidaPintarDisparoAlien:
   jr $ra
  
  
moverDisparoAlien:
   la $t0, coordenadasDisparoAlien
   lw $t1, 4($t0) # y de coordenada
   lw $t2, 0($t0) # x de coordenada
   
   #verificar si bay un disparo de Alien 
   beq $t1, 0, salidaMoverDisparoAlien
   
   lw $a0, colorNegro
   
   addi $sp, $sp, -4
   sw $ra, 0($sp)
   jal pintarDisparoAlien
   lw $ra, 0($sp)
   addi $sp, $sp, 4
   
   lw $a0, colorRojo
   
   lw $t1, 4($t0) # y de coordenada
   addi $t1, $t1, 1
   sw $t1, 4($t0)
   
   addi $sp, $sp, -4
   sw $ra, 0($sp)
   jal pintarDisparoAlien
   lw $ra, 0($sp)
   addi $sp, $sp, 4
   
   li $a0, 15000
   
   addi $sp, $sp, -4
   sw $ra, 0($sp)
   jal retardo
   lw $ra, 0($sp)
   addi $sp, $sp, 4
   
salidaMoverDisparoAlien:
   jr $ra

verificarColisionDisparoNave:
  la $t0, coordenadasDisparoAlien
  
  lw $t1, 0($t0)
  slt $t8, $s0, $t1
  beq $t8, 0, saltarVerificacionDisparoNave
  
  addi $t2, $s0, 11
  slt $t8, $t1, $t2
  beq $t8, 0, saltarVerificacionDisparoNave
  
  lw $t1, 4($t0) 
  li $t3, 56
  
  slt $t8, $t3, $t1
  beq $t8, 0, saltarVerificacionDisparoNave
  
   li $v0, 4           
   la $a0, final     
   syscall 
  
saltarVerificacionDisparoNave:
  jr $ra
 
   
   

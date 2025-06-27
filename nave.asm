.data
    displayAddress:         .word 0x10008000

    addrTeclaPresionada:    .word 0xffff0000   # dirección de memoria donde se almacena si la tecla fue presionada
    addrCodigoTecla:        .word 0xffff0004   # dirección de memoria donde se almacena la tecla presionada (ASCII)

    colorVerde:             .word 0x00FF00     # color verde
    colorNegro:             .word 0x000000     # color negro
    colorBlanco:            .word 0xFFFFFF     # color blanco

.text
    lw $t0, displayAddress        # $t0 = dirección base del display
    lw $t1, colorVerde            # $t1 = color verde
    lw $t2, addrTeclaPresionada  # $t2 = dirección de memoria donde se almacena si la tecla fue presionada
    lw $t3, addrCodigoTecla      # $t3 = dirección donde se almacena la tecla presionada (ASCII)
    lw $t4, colorNegro           # $t4 = color negro

    li $s0, 0     # $s0 = posición de la nave (en el eje x)
    li $s1, 0     # $s1 = ¿está disparando?
    li $s2, 0     # $s2 = dirección del disparo
    addi $s3, $t0, 14336         # $s3 = dirección de spawneo de la nave

    # Prueba de la creación de alien1 y 2
    move $a0, $t0
    move $a1, $t1
    jal pintarAlien1 

    addi $t0, $t0, 52
    move $a0, $t0
    move $a1, $t1
    jal pintarAlien2 
    addi $t0, $t0, -52

    move $a0, $s3              # posición actual de la nave
    move $a1, $t1              # color verde
    jal pintarNave

juego:
    move $a0, $s2              # dirección del disparo
    move $a1, $s1              # ¿está disparando?
    jal actualizarDisparo
    move $s2, $v0              # actualizar dirección del disparo
    beq $s2, $zero, cambiar

    addi $s1, $s1, 1           # aumentar estado de disparo

subjuego:
    lw $t5, 0($t2)             # conocer si una tecla fue presionada
    beq $t5, $zero, juego      # si no fue presionada, repetir el loop

    lw $t6, 0($t3)             # cargar la tecla presionada en ASCII
    beq $t6, 0x00000061, letraA    # si la tecla fue 'a', ir a instrucciones correspondientes
    beq $t6, 0x00000020, espacio   # si la tecla fue espacio, ir a instrucciones correspondientes
    bne $t6, 0x00000064, juego     # si la tecla no fue 'd', ni las anteriores, repetir el loop
    beq $s0, 53, juego             # si ya está muy a la derecha, no puede moverse más

    addi $s0, $s0, 1               # aumentar posición x en 1

    # llamado función pintar (posiciónActual, negro)
    move $a0, $s3
    move $a1, $t4                  # guardar negro como argumento
    jal pintarNave

    addi $s3, $s3, 4               # aumentar en 4 el offset de la dirección del pixel
    move $a0, $s3

    # llamado función pintar (posiciónActual, verde)
    move $a1, $t1                  # guardar verde como argumento
    jal pintarNave
    j juego                        # repetir

cambiar:
    li $s1, 0                      # reiniciar estado de disparo
    j subjuego

letraA:
    beq $s0, 0, juego              # si ya está muy a la izquierda, no puede moverse más

    # llamado función pintar (posiciónActual, negro)
    move $a0, $s3
    move $a1, $t4                  # guardar negro como argumento
    jal pintarNave

    addi $s3, $s3, -4              # disminuir en 4 el offset de la dirección del pixel
    addi $s0, $s0, -1              # disminuir posición x en 1

    # llamado función pintar (posiciónActual, verde)
    move $a0, $s3
    move $a1, $t1                  # guardar verde como argumento
    jal pintarNave
    j juego                        # repetir

espacio:
    bne $s1, $zero, juego          # si ya está disparando, ignorar

    move $a0, $s3                  # dirección de spawneo de la nave
    move $a1, $s1
    jal disparo
    move $s2, $v0                  # dirección que maneja el disparo
    li $s1, 1                      # activar estado de disparo
    j juego

# funciones

disparo:
    lw $t7, colorBlanco            # color blanco  
    addi $t6, $a0, -236            # centrar el disparo de la nave
    sw $t7, 0($t6)
    sw $t7, -256($t6)
    move $v0, $t6
    jr $ra

actualizarDisparo:
    beq $a0, $zero, exit
    beq $a1, 60, alternative

    lw $t7, colorBlanco            # color blanco
    lw $t8, colorNegro             # color negro
    sw $t8, 0($a0)
    addi $t6, $a0, -256            # subir el disparo de la nave
    sw $t7, -256($t6)

    li $a0, 5
    li $v0, 32
    syscall

    move $v0, $t6
exit:
    jr $ra

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


/* En este archivo escribirás tu solución.
 * Para ello deberás completar las rutinas en código
 * ensamblador.
 * Puedes usar los registros R0 a R12 pues ya está preservado
 * el valor de los registros que deben mantenerse.
 * Los registros R0 a R3 contienen los argumentos al entrar a
 * la rutina y contendrán el valor devuelto al salir.
 * Si realizas un llamado a subrutina, los registros R0 a R3 y el
 * registro R12 pueden cambiar su valor (y en particular, R0 contiene 
 * normalmente el valor devuelto), los registros R4 a R11 preservan
 * su valor.
 */
.syntax unified
.cpu cortex-m3
.fpu softvfp
.thumb

.macro defun nombre
    .section .text.\nombre
    .global \nombre
    .type \nombre, %function
\nombre:
.endm

.macro endfun nombre
    .size \nombre, . - \nombre
.endm


/**
 * Sumar dos enteros de 32 bit
 *  suma(2,3) => 5
 * Entrada
 *  a->R0, b->R1 : sumandos, enteros de 32 bit con signo 
 * Salida
 *  R0     : suma, entero de 32 bit con signo
 */
defun suma
    push {r4-r11,lr}

    ADD R0, R1

    pop {r4-r11,pc}
endfun suma

/**
 * Sumar los números de un arreglo en memoria de enteros de
 * 32 bit con resultado de 64 bit.
 *
 * sumatoria(5,(uint32_t[]){1,2,3,4,5}) => 15
 *
 * Entrada 
 *  n->R0    : Cantidad de números en registro R0, entero de 32 bit
 *  b->R1    : Dirección en memoria del primer número, puntero a
 *             entero de 32 bit con signo.
 * Salida
 *  R1:R0 : Sumatoria, entero de 64 bit con signo 
 */
defun sumatoria
    push {r4-r11,lr}

    mov R3, R0 //En R3 se guarda "n"
    mov R4, R1 //En R4 se guarda "b"

    mov R0, #0 // R0 se inicializa en 0 (primeros 32 bits de A)
    mov R1, #0 // R1 se inicializa en 0 (últimos 32 bita de A)

    mov R2, #0 // En R2 se guarda "i" y se inicializa en 0

    lazo_sum:
        cmp R2, R3 // flags <- i-n
        bge fin_sum  // Salta a la etiqueta fin_sum, si i >= n

        ldr R5, [R4,R2,lsl #2] // aux <- b[i]

        adds R0, R0, R5 // A la parte inferior de A (R0) se le suma b[i]
        add R1, R1, #0 // Si hubiera un carry, se suma a la parte superior de A (R1)

        adds R2, R2, #1 // Incrementa el índice en 1

        b lazo_sum  // Repite el Lazo, mientras i sea menor que n

    fin_sum:
        pop {r4-r11,pc}

endfun sumatoria

/**
 * Encuentra la posicion del máximo elemento de un arreglo
 *
 * posicion_maximo(4,(uint32_t[]){1,4,2,3}) => 1
 *
 * Entrada:
 *  n->R0 : cantidad de números en el arreglo, entero de 32 bit
 *  b->R1 : posición en memoria del primer número, puntero
 *          a entero de 32 bit con signo.
 * Salida:
 *  R0 : posición del máximo elemento en el arreglo, entero
 *       de 32 bit.
 */
defun posicion_maximo
    push {r4-r11,lr}

    mov R3, R0 // En R3 se guarda "n", cantidad de números
    mov R4, R1 // En R4 se guarda "b", arreglo de n números

    mov R2, #0 // R2 se inicializa en 0 y guarda "MAX", VALOR del máximo número
    mov R1, #0 // R1 se inicializa en 0 y guarda "i", índice
    mov R0, #0 // R0 se inicializa en 0 y guarda "k", POSICIÓN del máximo número del arreglo

    condicional_pos_max:
        cmp R3, #1 // flags <- n-1
        ble fin_pos_max // Salta a la etiqueta fin_pos_max si n <= 1

        ldr R2, [R4,R0,lsl #2] // MAX <- b[k]
        mov R1, #1 // Se asigna i <- 1

        b lazo1_pos_max // Salta a la etiqueta lazo1_pos_max
    
    lazo1_pos_max:
        cmp R1, R3 // flags <- i-n
        bge fin_pos_max  // Salta a la etiqueta fin_pos_max, si i >= n

        b lazo2_pos_max // Salta a la etiqueta lazo2_pos_max

    lazo2_pos_max:
        ldr R5, [R4,R1, lsl #2] // A una variable auxiliar en R5 se le asigna b[i] 

        cmp R2, R5 // flags <-  MAX-b[i]
        bge aumetar_indice  // Salta a la etiqueta aumentar_indice, si MAX >= b[i]   

        mov R2, R5 // MAX <- b[i]
        mov R0, R1 // k <- i

        b aumentar_indice // Salta a la etiqueta aumentar_indice
    
    aumentar_indice:
        adds R1, R1, #1 // Se incrementa el índice en 1

        b lazo1_pos_max // Salta de regresa a la etiqueta lazo1_pos_max mientras i<n

    fin_pos_max:
        pop {r4-r11,pc}
endfun posicion_maximo 

/**
 * Ordenar de menor a mayor un arreglo de números en memoria.
 * La ordenación es en el lugar, sobreescribiendo el arreglo
 * original.
 *
 * uint32_t vals[]={4,1,3,5,2,6,7};
 * ordenar_en_sitio_menor_a_mayor(7,vals)
 * luego vals contendrá {1,2,3,4,5,6,7}
 *
 * Entrada:
 *  n->R0 : Cantidad de números en el arreglo, entero de 32 bit
 *  b->R1 : Dirección del primer número, puntero a entero de
 *          32 bit con signo.
 * Salida:
 *  Sin valor de salida. El arreglo dado debe haber sido ordenado
 *  sobreescribiendo los valores originales.
 */
defun ordenar_en_sitio_menor_a_mayor
    push {r4-r11,lr}
    
    mov R0, R0 // En R0 se guarda "n", cantidad de números en el arreglo
    mov R1, R1 // En R1 se guarda "b", arreglo de n números de 32 bits
    mov R2, #0 // En R2 se guarda "k" y se inicializa en 0

    subs R3, R0, #1 // En R3 se guarda n-1
    mov R2, R3 // k <- n-1

    b lazo_ordenar // Salta a la etiqueta lazo_ordenar

    lazo_ordenar:
        cmp R2, #0 // flags <- k-0
        ble fin_ordenar // Salta a la etiqueta fin_ordenar si k <= 0

        /*Se hace una llamada a subrutina. Reservamos R4 para el índice "j" y le asignamos pos_max*/

        mov R5 , #0 // En R5 se guarda "x" y se inicializa en 0

        ldr R6, [R1,R2, lsl #2] // En R6 se guarda b[k] 
        ldr R7, [R1,R4, lsl #2] // En R7 se guarda b[j]

        mov R5, R6 // x <- b[k]
        mov R6, R7 // b[k] <- b[j]
        mov R7, R5 // b[j] <- x

        subs R2, R2, #1 // Se resta 1 del valor de k

        b lazo_ordenar // Repite el lazo hasta que k <= 0

    fin_ordenar:
        pop {r4-r11,pc}
endfun ordenar_en_sitio_menor_a_mayor

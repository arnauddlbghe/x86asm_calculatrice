.data
# Limite de la saisie.
buffer:
    .space 32

resultat:
    .space 32

msgErreur:
    .string "[!] Erreur\n"
    .space 19

.text

.globl _start

 
_start:

# ================================================================================================================
# Lecture de la saisie utilisateur.
# ================================================================================================================
read:
    movq $0, %rax                           # 0 is the 'read' instruction
    movq $0, %rdi                           # 0 indicate that the input is the keyboard*/
    movq $buffer, %rsi                      # rsi contains the adress of where to put the data*/
    movq $32, %rdx                          # rdx contains the number of octets to read*/
    syscall                                 # appel systeme


# ================================================================================================================
# DEFINITION DES VALEURS INITIALES DES REGISTRES.
# ================================================================================================================
init:   
    movq $buffer, %r8                       # r8    -> Contient la saisie utilisateur.
    movq $0, %r9                            # r9    -> Contient le resultat de l'operation saisie.
    movq $0, %r10                           # r10   -> Contient le caractere ou l'entier a convertir.
    movq $0, %r11                           # r11   -> Contient le caractere ou l'entier convertit/construit.
    movq $10, %r14                          # r14   -> Registre utilise pour les divisions/multiplications.


# ================================================================================================================
# LECTURE DU CARACTERE.
# ================================================================================================================
lectureCaractere:
    movb (%r8), %r10b                       # On recupere le caractere a convertir.
    addq $1, %r8                            # On actualise le pointeur sur le prochain caractere.

    cmp $32, %r10                           # ' ' == %r10  ? 
    je traitementEspace                     # Oui, jump traitementEspace
    
    cmp $43, %r10                           # '+' == %r10  ? 
    je traitementAddition                   # Oui, jump traitementAddition
    cmp $45, %r10                           # '-' == %r10  ? 
    je traitementSoustraction               # Oui, jump traitementSoustraction
    cmp $42, %r10                           # '*' == %r10  ? 
    je traitementMultiplication             # Oui, jump traitementMultiplication
    cmp $47, %r10                           # '/' == %r10  ? 
    je traitementDivision                   # Oui, jump traitementDivision

    cmp $10, %r10                           # '\n' == %r10 ? 
    je traitementFinProgramme               # Oui, jump traitementFinProgramme
    
    cmp $48, %r10                           # '0' > %r10   ? 
    jl traitementErreur                     # Oui, jump traitementErreur
    cmp $57, %r10                           # '9' < %r10   ? 
    jg traitementErreur                     # Oui, jump traitementErreur
    
    jmp traitementChiffre                   # Si aucun de ces cas n'est arrive, %r10 contient bien un chiffre.


# ================================================================================================================
# TRAITEMENT SELON LE CARACTERE LU.
# ================================================================================================================
traitementFinProgramme:
    movq %rax, %r9                          # Le resultat, en entier, est stocke dans r8
    
    movq $0, %rax
    movq $0, %rbx
    movq $0, %rdx

    movq %r9, %r10                          # Premier argument des operations,
    movq $0, %r11                           # Deuxieme argument des operations.
    
    movq $0, %r15                           # Compteur du nombre de dision realisees
    movq $resultat, %r8                     # r8 prend l'adresse du buffer de resultat. 
    
    jmp convertIntToChar

traitementEspace:
    push %r11
    movq $0, %r11
    jmp lectureCaractere


traitementAddition:
    pop %rbx                                # Deuxieme argument.
    pop %rax                                # Premier argument
    add %rbx, %rax                          # Addition, resultat dans %rax
    movq %rax, %r9                          # On met le resultat dans %r9
    movq %r9, %r11
    jmp lectureCaractere

traitementSoustraction:
    pop %rbx                                # Deuxieme argument.
    pop %rax                                # Premier argument
    sub %rbx, %rax                          # Soustraction, resultat dans %rax
    movq %rax, %r9                          # On met le resultat dans %r9
    movq %r9, %r11
    jmp lectureCaractere

traitementMultiplication:
    pop %rbx                                # Deuxieme argument.
    pop %rax                                # Premier argument
    imul %rbx                               # Multiplication, resultat dans %rax
    movq %rax, %r9                          # On met le resultat dans %r9
    movq %r9, %r11
    jmp lectureCaractere

traitementDivision:
    pop %rbx                                # Deuxieme argument.
    pop %rax                                # Premier argument
    idiv %rbx                               # Division, resultat dans %rax
    movq %rax, %r9                          # On met le resultat dans %r9
    movq %r9, %r11
    jmp lectureCaractere


traitementChiffre:
    subq $48, %r10                          # Conversion en nombre entier
    movq %r11, %rax                         # On multiplie par 10 le nombre en train d'etre construit.
    imul %r14                               # imul multiplie la valeur dans %rax par la valeur dans %r14 et met le resultat dans %rax
    movq %rax, %r11                         # On remet le resultat de la multiplication dans %r11 car %rax est utilise ailleurs.
    addq %r10, %r11                         # On ajoute au nombre le chiffre lu.
    jmp lectureCaractere


traitementErreur:
    movq $msgErreur, %r9
    jmp write


# ================================================================================================================
# CONVERSIONS. (INT -> CHAR | CHAR -> INT)
# ================================================================================================================
convertIntToChar:
    # r8 contient l'adresse memoire du buffer pour le resultat
    # r10 contient le resultat (entier)
    # 15 contient le nombre de caracteres a convertir

    movq %r10, %rax
    idiv %r14                               # Division de %rax par %r14 (Division par 10), reste de la divison dans %rdx

    movq %rax, %r10                         # On met le resultat de la division dans r10
    movq %rdx, %r11                         # On met le reste de la division dans r11
    movq $0, %rax
    movq $0, %rdx

    add $48, %r11                           # Conversion en char le reste de la division
    push %r11

    inc %r15

    cmp $0, %r10                            # Si r10 vaut 0, on a plus rien a diviser.
    je printResultat
    jne convertIntToChar

# ================================================================================================================
# ECRITURE DU RESULTAT.
# ================================================================================================================
printResultat:
    pop %r9                                 # r9 contient un caractere.

    movb %r9b, (%r8)                        # On ajoute le caractere.
    addq $1, %r8                            # On actualise le pointeur sur le prochain caractere.

    dec %r15
    cmp $0, %r15
    je write
    jne printResultat

write:                                      # Cette etape ecrit sur la sortie standard
    movb $10, (%r8)
    movq $1, %rax                           # rax <- (write)
    movq $1, %rdi                           # rdi <- (stdout)
    movq $resultat, %rsi                    # rsi <- (resultat)
    movq $32, %rdx                          # rdx <- (longueur chaine)
    syscall                                 # appel systeme


# ================================================================================================================
# FIN DU PROGRAMME.
# ================================================================================================================
exit:
    mov $60, %rax
    xor %rdi, %rdi
    syscall

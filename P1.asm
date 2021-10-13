;Parasykite programa, kuri ivestoje simboliu eiluteje mazasias raides pakeicia didziosiomis, o didziasias mazosiomis ir atspausdina eilutes ilgi;
;        Pvz.: ivedus abSDGasR turi atspausdinti ABsdgASr (ilgis 8)

.model small

.stack 100h

.data
	bufDydis	DB 255
	kiek		DB ?
	buferis		DB 255 dup (?)
	pranesimas1	DB "Iveskite eilute $"
	pranesimas2	DB "Sukeista: $"
	pranesimas3	DB " (ilgis $"
	pranesimas4	DB ")$" 
	enteris		DB 10, 13, '$'

.code

Pradzia:
	MOV ax, @data		
	MOV ds, ax			


	MOV ah, 09h
	MOV dx, offset pranesimas1
	INT 21h

	MOV ah, 0Ah		;buffered input
	MOV dx, offset bufDydis	;buffered input pradedamas nuo adreso, kur yra bufDydis. Tada automatiskai bus nuskaitomas ivestu simboliu kiekis ir 
	INT 21h 					; idedamas i "kiek" (jis atmintyje yra vienu baitu toliau). ivesti simboliai eina i "buferis"

	MOV ah, 09h
	MOV dx, offset enteris
	INT 21h

	MOV ax, 0		; isvalom ax
	MOV cl, kiek		; i cl isidedam kiek simboliu buvo nuskaityta
	MOV ch, cl		; cl reiksme nukopijuojam i ch

	MOV bx, offset buferis	; i bx isidedam "buferis" pradzios adresa

Ciklas:
	CMP byte ptr [ds:bx], 'A'	; pagal ascii lentele tikrinam kokie simboliai ivesti
	JB Nekeisti			; ignoruojam jei simbolis ne raide
	CMP byte ptr [ds:bx], 'Z'
	JBE Prideti			; jei ivesta didzioji raide, is jos reikia atimti 20h ir tada ji patampa mazaja. atvirksciai su didziosiomis.
	CMP byte ptr [ds:bx], 'a'
	JB Nekeisti
	CMP byte ptr [ds:bx], 'z'
	JBE Atimti

	JMP Nekeisti

Prideti:
	ADD byte ptr [ds:bx], 20h
	JMP Nekeisti

Atimti:
	SUB byte ptr [ds:bx], 20h

Nekeisti:
	INC bx		; padidinam bx vienu, ty. dabar ziuresim i simboli, kuris atmintyje yra viena pozicija toliau
	DEC cl		; is cl atimam viena
	CMP cl, 0	; ziurim ar dar yra ivestu ir nenuskaitytu simboliu. Jei yra, vel sokam i Cikla
	JNE Ciklas
			
	MOV byte ptr [ds:bx], '$'	; jei visi ivesti simboliai yra patikrinti, i buferio pabaiga isidedam '$' - eilutes pabaigos simboli
													; (jis reikalingas spausdinimui)
	MOV ah, 09h
	MOV dx, offset pranesimas2
	INT 21h			

	MOV ah, 09h
	MOV dx, offset buferis
	INT 21h			

	MOV ah, 09h
	MOV dx, offset pranesimas3
	INT 21h			

	MOV cl, ch
	MOV ch, 0	; dabar visam cx'e yra tik pradine cl reiksme

	XOR ax, ax	; nusinulinam ax
	MOV ax, cx	; cx isidedam i aritmetini registra (ax)
	CALL Skaiciavimas	; einam i procedura

	MOV ah, 09h
	MOV dx, offset pranesimas4
	INT 21h


	MOV ah, 4Ch
	INT 21h


Skaiciavimas PROC
	PUSH ax		; issisaugom registrus steke. juos veliau vel grazinsim jei ju prireiktu ateity
	PUSH cx
	PUSH dx
	MOV cx, 10
	PUSH "$$"	; reikia isidet du eilutes pabaigos simbolius, kad zinotumem kur pradejom deti norimas atspausdint reiksmes i steka
Dalinimas:
	MOV dx, 0	; nusinulinam dx
	DIV cx		; dalyba. ax/cx. ax lieka sveikoji dalis, o i dx nueina liekana.
	PUSH dx		; liekana imetam i steka
	CMP ax, 0	; ziurim ar dar yra reiksmiu, kurios dar neidetos i steka
	JA Dalinimas
Spausdinimas:
	POP dx		; is steko pasiimam idetas reiksmes ir spausdinam
	CMP dx, "$$"
	JE Pabaiga

	MOV ah, 02h
	ADD dl, '0'	; prie skaitment pridejus '0' jis patampa simboliu, kuri galima atspausdint
	INT 21h

	JMP Spausdinimas
Pabaiga:
	POP dx		; susigrazinam steke issaugotus, nepakitusius duomenis
	POP cx
	POP ax
	RET		;	proceduros
Skaiciavimas ENDP	;	pabaiga


END Pradzia

clearcalc:
	rm calculatrice.o
	rm calculatrice

calculatrice:
	as --gstabs -o calculatrice.o calculatrice.s
	ld -o calculatrice calculatrice.o

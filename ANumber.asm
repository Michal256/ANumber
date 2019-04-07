;====================Autor pracy: Michał Ziółek====================
;Inicjalizacja stosu
stos0 segment STACK
	db 1024 dup(?)
stos0 ends

;Inicjalizacja pamięci dla ekranu
ekran segment at 0B800h
	ek db ?
	atr db ?
ekran ends

;Deklaracja podstawowych danych
dane0 segment
	tstart0 db "Witaj!",0AH,"Wybierz numer:",0AH,"1 (Zagraj)",0AH,"2 (Wyjdz)$"
	tstart1 db "Podaj sume do uzbierania(max. 999)(po wpisaniu nacisnij przycisk enter): $"
	tstart2 db "Podaj czas w seknudach(max. 999)(po wpisaniu nacisnij przycisk enter): $"
	tscore0 db "Potrzebne:$"
	tscore1 db "Masz:$"
	tczas db "Czas:$"
	sumal db 5 dup(?)
	czas db 5 dup(?)
	tpusteznaki db "                                                                                $"
	tpustepole db "$"
	sumau dw 4 dup(?)
	cord_p dw 2 dup(?)
	cord_w dw 2 dup(?)
	cord_w2 dw 2 dup(?)
	czasdo_losuj dw 2 dup(?)
	czas_ostatni db "              $"
	gow_liczba dw 3 dup(?)
	offset_liczb dw 10 dup(0)
	buffor_licznik db 1 dup(?)
	koniec_gry_o db "Koniec Gry!$"
	koniec_gry_o2 db "Nacisnij klawisz, aby wyjsc...$"
	koniec_gry_p db "Nie udalo Ci sie zebrac odpowiedniej liczby punktow!$"
	koniec_gry_w db "Wygrana! Udalo Ci sie zebrac odpowiednia ilosc punktow!$"
	tkolor db 1 dup(?);zmienna pomocniczna do przechowania koloru do wyswietlenia
	
dane0 ends

main segment
assume cs:main,ds:dane0,es:ekran,ss:stos0 ;powiązanie
start:

	;wczytanie trybu tekstowego 80x25 CGA Kolorowy
	mov ah,00h
	mov al,03h
	int 10h
	;Przestawienie kursora
	mov ah,02h
	mov bh,0;Strona
	mov dh,0;Wiersze
	mov dl,34;Kolumny
	int 10h
	
	;Wymagane zerowanie dx
	mov dx,0
	;Wypisanie tekstu
	mov ax,seg dane0
	mov ds,ax
	mov ah,9h
	int 21h
	


	petla0:
		mov ah,10h
		int 16h
		;W al dostaje ascii znak
		;ah scan code
		;jesli al=2
		cmp al,32H
		je exit
		;jesli al=1
		cmp al,31H
		je zagraj
	loop petla0
	
	exit:
	mov ax, 4c00h
	int 21h
	
	zagraj:
	;Start
	mov ah,00h
	mov al,03h
	int 10h
	
	mov dx,offset tstart1
	mov ah,09h
	int 21h
	
	
	;Sprzatanie
	mov dx,0
	mov cx,0
	mov si,0
	;Etap wpisywania liczb
	petlap:
		
		;Pobranie znaku do al
		mov ah,10h
		int 16h
		
		;wrzucam zawartosc al do zmiennej sumal
	
		mov sumal[si],al;Wrzucam do sumal to co wczytal
		mov sumau[si],30H;Uzupelniam jeszcze zmienna ptorzebna pozniej przy zbieraniu
		add si,1;przesuwam o 1 offset dalej
		
		
		;Wypisanie znaku na ekran
		mov ah,0Eh
		mov bh,0
		int 10h

		
		;Zeruje w razie co ah
		mov ah,0
		cmp al,0DH
		je poprawnyenter
		jne petlap
	loop petlap
	

	poprawnyenter:
	;Musze zakonczyc wczytywanie do zmiennej
	mov sumal[5],"$"
	mov sumau[si-1],0DH
	mov sumau[6],0024H

	;Nowy ekran
	mov ah,00h
	mov al,03h
	int 10h

	;sprzatanie
	mov ax,0
	mov bx,0
	mov cx,0
	mov dx,0
	mov si,0
	
	
	;Koniec Teraz czas
	mov dx,offset tstart2
	mov ah,09h
	int 21h
	;------Czas
	petlap2:
		
		;Pobranie znaku do al
		mov ah,10h
		int 16h
		
		;wrzucam zawartosc al do zmiennej sumal
	
		mov czas[si],al;Wrzucam do czas to co wczytal
		add si,1;przesuwam o 1 offset dalej
		
		
		;Wypisanie znaku na ekran
		mov ah,0Eh
		mov bh,0
		int 10h
		
		;Zeruje w razie co ah
		mov ah,0
		cmp al,0DH
		je poprawnyenter2
		jne petlap2
	loop petlap2
	

	poprawnyenter2:
	;Musze zakonczyc wczytywanie do zmiennej
	mov czas[si],"$"
	
	;sprzatanie2
	mov ax,0
	mov bx,0
	mov cx,0
	mov dx,0
	mov si,0
	

	;------Koniec wczyt. czasu
	mov ah,00h
	mov al,03h;Tryb tekstowy 80x25 kolor
	int 10h
	
	mov ax,0;Czyszczenie
	mov bx,0
	mov cx,0
	mov dx,0

	;------Rysowanie
	;Rysujemy plansze, 1 linia
	;do si stringa do 80 znakow
	;do dl-liczba kolumn do dh liczba wierszy
	mov si,offset tpusteznaki
	mov dl,0
	mov dh,0
	mov tkolor[0],2FH;8BH miga
	call wyswietl_proc
	
	;Rysuje 2 linie
	mov si,offset tpusteznaki
	mov dl,0
	mov dh,1
	mov tkolor[0],2FH;8BH miga
	call wyswietl_proc
	
	;Rysuje 3 linie
	mov si,offset tpusteznaki
	mov dl,0
	mov dh,2
	mov tkolor[0],2FH;8BH miga
	call wyswietl_proc
	
	
	;Tekst na rysunek zielonej
	mov si,offset tscore0
	mov dl,2
	mov dh,0
	mov tkolor[0],2FH
	call wyswietl_proc
	
	
	mov si,offset sumal
	mov dl,5
	mov dh,1
	mov tkolor[0],21H
	call wyswietl_proc
	
	mov si,offset tscore1
	mov dl,36
	mov dh,0
	mov tkolor[0],2FH
	call wyswietl_proc
	
	mov si,offset sumau
	mov dl,37
	mov dh,1
	mov tkolor[0],21H
	call wyswietl_proc
	
	mov si,offset tczas
	mov dl,73
	mov dh,0
	mov tkolor[0],2FH
	call wyswietl_proc
	
	mov si,offset czas
	mov dl,74
	mov dh,1
	mov tkolor[0],21H
	call wyswietl_proc
	
	;80x25
	mov cl,25
	mov ch,0
	;wypelniam czarne pole
	petla2:
	mov si,offset tpusteznaki
	mov dl,0
	mov dh,cl
	mov tkolor[0],00H
	PUSH CX
	mov cx,0
	call wyswietl_proc
	POP CX
	dec cl
	cmp cl,2
	je dalejp2
	jne petla2
	loop petla2
	dalejp2:
	
	;Koniec wczytywania pustych znakow do pamieci ekranu. Teraz mozna ustawiac dowolny obiekt poprzez offsety
	;Reset
	mov cx,0
	mov dx,0
	;Domyslne ustawienie kursora
	
	
	;80x25 strzalka ma 2 wiersze 
	;Rejestr seg ekranu, bede na nim operowal
;ETAP GENEROWANIA LUDZIKA

		;ustalam poczatek pozycje poczatkowa zapisuje w zmiennych przyszle offesty ludzika srodek
		mov si,offset cord_p
		mov si[0],1997D
		mov word ptr si[2],0024H
		mov si,offset cord_w
		mov si[0],1837D
		mov word ptr si[2],0024H
		mov si,offset cord_w2
		mov si[0],2157D
		mov word ptr si[2],0024H
		;Czas do losowania
		mov si,czasdo_losuj
		mov word ptr si[0],0002D
		mov word ptr si[2],0024H
		;Odczyt czasu, zaczynam liczyc czas
		mov ah,2Ch ;odczyt zegara
		int 21h;
		;CH-godzina CL-Minuta DH-Sekunda DL-1/100sec
		;Wrzucam na stos czyszcze co nie potrzebne
		mov cx,0
		mov dl,0
		PUSH dx
		mov dh,0
		
		mov ax,seg ekran
		mov es,ax
		;----
		;z tego czytam hex
		mov si,offset cord_p
		mov bx,si[0]
		mov ek[bx-4],0E0H;kolor;DOLNA PODSTAWA
		mov ek[bx-2],78H;kolor
		mov ek[bx],78H;kolor
		mov ek[bx+2],78H;kolor
		mov ek[bx+4],0E0H;kolor
		;--
		mov si,offset cord_w
		mov bx,si[0]
		mov ek[bx-2],78H;GORNA PODSTAWA
		mov ek[bx],78H
		mov ek[bx+2],78H
		;--
		mov si,offset cord_w2
		mov bx,si[0]
		mov ek[bx-2],78H;GORNA PODSTAWA2
		mov ek[bx],78H
		mov ek[bx+2],78H
		
		mov dx,offset tpustepole;wyzerowac sie nie da a w dx musi cos przechowac, niech wiec przechowa tylko dolara
		mov ah,09h
		int 21h
		
		mov ax,0
		mov bx,0
		mov cx,0
		mov dx,0
		
	;Poczatkowa lokacja gotowa
	;80*2 to jedna linia
	;160*12 to srodek 1920 wzgledem wierszy, wedlug kolumn to 1920+80=2000
	
	petla3:
			;w al dostane znak w hex

		mov cl,10
		;usprawnic losowanie liczb przez opoznienie
		call delay_sth
		mov ah,2Ch ;odczyt zegara
		int 21h;
		
		
		mov bx,0
		mov si,offset buffor_licznik
		mov bl,si[0]
		mov czas_ostatni[bx],dl
		mov czas_ostatni[bx+1],dh
		inc bx
		inc bx
		cmp bx,0018D
		je resetbl
		jne dalejbl
		resetbl:
		mov bx,0
		jmp dalejbl
		dalejbl:
		mov buffor_licznik[0],bl
		mov bx,0
		
		;CH-godzina CL-Minuta DH-Sekunda DL-1/100sec
		mov cx,0
		mov dl,0
		POP cx;Wrzucam stary czas do cx w ch bede mial sekundy stare w dh nowe
		PUSH DX
		cmp ch,dh
		je bez_losuj_liczbe_p3_b
		jne odejmij_czas
		
		odejmij_czas:
		
		mov ax,0
		mov cx,0
		mov dx,0
		
		;w si jest zmienna do odjecia;bl odpowiada za to ile ma odjac
		
		mov si,offset czas
		mov bl,1D
		call odejmij_wartosc
		;funkcja odejmuje odpowiednio dla liczby max 999
		;funkcja zwraca dl
		cmp dl,55;Zwraca w dl procedura, dl jessli 55 to koniec gry
		je wyjdzzgryb
		jne dalej_graj_gracz
		
		
		petla3b:
		jmp petla3;odstep
		
		wyjdzzgryb:
		jmp wyjdzzgry
		
		dalej_graj_gracz:
		
		;Aktualizacja czasu na ekranie	
		mov si,offset czas
		mov dl,74
		mov dh,1
		mov tkolor[0],21H
		call wyswietl_proc
		
		mov ax,0
		mov bx,0
		mov cx,0
		mov dx,0
		
		mov si,czasdo_losuj
		dec word ptr si[0]
		mov bx,si[0]
		cmp word ptr si[0],0001D
		je losuj_liczbe_p3
		jne bez_losuj_liczbe_p3_b
		
		bez_losuj_liczbe_p3_b:
		jmp bez_losuj_liczbe_p3
		
		losuj_liczbe_p3:
;---------------------------------------Losowanie
		
		mov ax,0
		mov bx,0
		mov cx,0
		mov dx,0
		;Kasowanie tego co bylo, zamiana na spacje miejsc z liczbami
		mov di,0
		px1:
		mov bx,offset_liczb[di]
		mov ek[bx],20H
		add di,2
		cmp di,18
		je popx1
		jne px1
		
		popx1:
		mov di,0
		mov bx,0
		mov ax,0
		mov dx,0
		
		;dostane w cl nowa wartosc
		
		mov bl,0;argument ktory czas ma brac pod uwage
		call losuj_random_offset
		;Losowanie offsetu
		mov offset_liczb[0],cx;Liczba 1
		
		add bl,2
		call losuj_random_offset
		mov offset_liczb[2],cx;Liczba 2
		
		add bl,2
		call losuj_random_offset
		mov offset_liczb[4],cx;Liczba 3
		
		add bl,2
		call losuj_random_offset
		mov offset_liczb[6],cx;Liczba 4

		add bl,2
		call losuj_random_offset
		mov offset_liczb[8],cx;Liczba 5
		mov gow_liczba[2],cx

		add bl,2
		call losuj_random_offset
		mov offset_liczb[10],cx;Liczba 6

		add bl,2
		call losuj_random_offset
		mov offset_liczb[12],cx;Liczba 7

		
		add bl,2
		call losuj_random_offset
		mov offset_liczb[14],cx;Liczba 8

		add bl,2
		call losuj_random_offset
		mov offset_liczb[16],cx;Liczba 9
		
		mov offset_liczb[18],0024H;Liczba 9
		mov gow_liczba[4],0024H
		mov cx,0
		mov ax,seg ekran
		mov es,ax
		
		
		
		;Wypisanie liczb z pseudo losowymi offsetami
		mov bx,offset_liczb[0]
		mov ek[bx],31H
		mov ek[bx+1],0FH
		
		mov bx,offset_liczb[2]
		mov ek[bx],32H
		mov ek[bx+1],0FH
		
		mov bx,offset_liczb[4]
		mov ek[bx],33H
		mov ek[bx+1],0FH
		
		mov bx,offset_liczb[6]
		mov ek[bx],34H
		mov ek[bx+1],0FH
		
		mov bx,offset_liczb[8]
		mov ek[bx],35H
		mov ek[bx+1],0FH
		
		mov bx,offset_liczb[10]
		mov ek[bx],36H
		mov ek[bx+1],0FH
		
		mov bx,offset_liczb[12]
		mov ek[bx],37H
		mov ek[bx+1],0FH
		
		mov bx,offset_liczb[14]
		mov ek[bx],38H
		mov ek[bx+1],0FH
		
		mov bx,offset_liczb[16]
		mov ek[bx],39H
		mov ek[bx+1],0FH
		mov dx,offset tpustepole;wyzerowac sie nie da a w dx musi cos przechowac, niech wiec przechowa tylko dolara
		mov ah,09h
		int 21h
		
		
		mov ax,0
		mov bx,0
		mov cx,0
		mov dx,0
		mov si,0
		
		
		;Czas powrot
		mov si,czasdo_losuj
		mov word ptr si[0],0007H
		mov word ptr si[2],0024H
		jmp bez_losuj_liczbe_p3
		
		petla3c:
		jmp petla3b;odstep
		
		bez_losuj_liczbe_p3:	
	
			;Sprzatanie
			mov ax,0
			mov bx,0
			mov cx,0
			mov dx,0
			mov si,0
			
			mov ah,11h
			int 16h
			PUSH AX
			
			;Czyszcze bufor klawiatury, inaczej zapamieta znak i juz go nie wczyta
			mov ah,0cH
			mov al,0
			int 21h
			
			POP AX
			
			
			
			;sprawdzam czy wczytal znak, jak nie to petla jeszcze raz
			cmp ah,00H
			je petla3c
			jne rusztamgo
			
		rusztamgo:
			
				
			cmp ah,48H;gora
			je m_gora
			
			cmp ah,4DH;prawo
			je m_prawo
			
			cmp ah,50H;dol
			je m_dol
			
			cmp ah,4BH;lewo
			je m_lewo
			
			cmp al,1BH;escape
			je wyjdzzgry
			jne petla3c
	
		m_gora:
			mov bl,0
			call wykonaj_ruch
;-------------------------------------------------DETEKCJA RUCHU
			mov si,cord_w[0]
			call detekcja_kolizji
			mov si,cord_w2[0]
			call detekcja_kolizji
			mov si,cord_p[0]
			call detekcja_kolizji
	
			jmp petla3c
		m_prawo:
		
			mov bl,1
			call wykonaj_ruch
		;--------------------
			mov si,cord_w[0]
			call detekcja_kolizji
			mov si,cord_w2[0]
			call detekcja_kolizji
			mov si,cord_p[0]
			call detekcja_kolizji
		
			jmp petla3c
		m_dol:
		
			mov bl,2
			call wykonaj_ruch
		;------------------
			mov si,cord_w[0]
			call detekcja_kolizji
			mov si,cord_w2[0]
			call detekcja_kolizji
			mov si,cord_p[0]
			call detekcja_kolizji
			
			jmp petla3c
		m_lewo:
			mov bl,3
			call wykonaj_ruch
		;-------------------		
			mov si,cord_w[0]
			call detekcja_kolizji
			mov si,cord_w2[0]
			call detekcja_kolizji
			mov si,cord_p[0]
			call detekcja_kolizji

			jmp petla3c
		wyjdzzgry:
			POP CX;ZAWSZE PRZEGRANA jesli tutaj trafi
			
			mov ah,00h
			mov al,03h
			int 10h
			mov ax,0
			mov bx,0
			mov cx,0
			mov dx,0
			mov si,0
			mov di,0
			
			mov si,sumau[0];2b
			mov bl,sumal[0];1b mniejszy
			mov bh,sumal[1];1b wiekszy
			
			cmp bx,si
			je next_spr1
			jne porazka
			
			next_spr1:
			mov si,sumau[2];2b
			mov bl,sumal[2]
			mov bh,sumal[3]
			
			cmp bx,si
			je wygrana
			jne porazka

			porazka:
			mov si,offset koniec_gry_o
			mov dl,35
			mov dh,9
			mov tkolor[0],0FH;8BH miga
			call wyswietl_proc
			
			mov si,offset koniec_gry_p
			mov dl,14
			mov dh,10
			mov tkolor[0],0FH;8BH miga
			call wyswietl_proc
			jmp napis_ent
			wygrana:
			
			mov si,offset koniec_gry_o
			mov dl,35
			mov dh,9
			mov tkolor[0],0FH;8BH miga
			call wyswietl_proc
			
			mov si,offset koniec_gry_w
			mov dl,14
			mov dh,10
			mov tkolor[0],0FH;8BH miga
			call wyswietl_proc
			
			napis_ent:
			mov si,offset koniec_gry_o2
			mov dl,26
			mov dh,11
			mov tkolor[0],8BH;8BH miga
			call wyswietl_proc
					
		mov ah,10h
		int 16h
		
		mov ah,00h
		mov al,03h
		int 10h
	


	

mov ax,0
mov bx,0
mov cx,0
mov dx,0
mov si,0
mov di,0
mov ax, 4c00h
int 21h

wyswietl_proc PROC NEAR

;Opis: Funkcja służy do wyświetlania ciągu na ekranie w wybranym miejscu i o wybranym kolorze. Tylko tryb tekstowy.
;do si stringa do 80 znakow do dl-liczba kolumn do dh liczba wierszy

	PUSH dx;musze cofnac na koncu do 0 by algorytm zadzialal
	mov bx,0;W BX bedzie licza liter, nizej jest zliczana petlap1
	petlap1:
		;w si przed wywolaniem siedzi offset tekstu
		;dh i dl sa juz ustawione
		mov al,si[bx]
		add bx,1

		cmp al,0DH;jesli napotka enter(w liczbach jest)
		je mamliczbe
		cmp al,24H;(do $ jesli nie enter)
		je mamliczbe
		jne petlap1
	loop petlap1
	
	mamliczbe:
	dec bx;Usunac dolara
	mov ax,0
	mov cx,0
	;Przestaw kursor tam gdzie podane przed wywolaniem
	mov ah,02h
	int 10h
	mov ah,0
	
	petla1:
		
		push bx;Ile liter jest w bx
		mov bx,ax;To co ostatnio bylo indeksem, juz zinkrementowanym
		mov ax,0
		
		mov al,si[bx]
		push bx;Wkladam na stos bo 0 musze miec potem
		mov bl,tkolor[0]
		mov bh,0
		mov cx,1;liczba znakow
		mov ah,09h
		int 10h
	
		;Bede przesowal kursor
		mov ah,02h
		POP bx
		add bx,1
		add dl,1
		int 10h
		
		mov ax,bx
		pop bx
		
		POP cx
		PUSH cx
		PUSH bx
		add bl,cl
		mov cx,0
		
		cmp bl,dl;do 80 znakow;w bl moze byc 40, a do dl tylko 25
		POP bx
		je koniec_p1
		jne petla1
	
	
	loop petla1
	koniec_p1:
	POP bx
	mov ax,0
	mov bx,0
	mov cx,0
	mov si,0
	
	RET
wyswietl_proc ENDP

;-------------
odejmij_wartosc PROC NEAR

;Opis: Funkcja służy do odejmowania czasu tz. dekrementowania liczby jedności dziesiątek lub setek. 
;Zwraca koniec jesli dl 55 to koniec gry
;w bl dostaje liczbe ktora mam odjac

	;spr czy 3 czy 2 cyforwa
	mov bh,si[2]
	cmp byte ptr bh,24H
	je jedno_cyfrowa
	
	cmp byte ptr bh,0DH
	je dwu_chyba_cyfrowa
	jne trzy_cyfrowa
		
		dwu_chyba_cyfrowa:
		mov bh,si[1]
		cmp byte ptr bh,0DH;mowie jaki typ ma...
		je jedno_cyfrowa
		jne dwu_cyfrowa
		
	
			trzy_cyfrowa:
			
				dec bl
				cmp byte ptr si[2],30H
				je od_dwu_3
				jne od_3
				
				spr_3:
				cmp bl,0
				je DALEJ_GRA
				jne trzy_cyfrowa
				
				
					od_3:
						dec byte ptr si[2]
						jmp spr_3
				
					od_dwu_3:
					
						cmp byte ptr si[1],30H
						je od_jed_3
						jne od_2
							
						od_jed_3:
							;KONIEC GRY
							cmp byte ptr si[0],30H
							je KONIEC_GRY
							jne od_1
							
							od_1:
							dec byte ptr si[0]
							mov byte ptr si[1],39H
							mov byte ptr si[2],39H
							jmp spr_3
							
						od_2:
							dec byte ptr si[1]
							mov byte ptr si[2],39H
							jmp spr_3
				
			dwu_cyfrowa:
				
				dec bl
				cmp byte ptr si[1],30H
				je od_dwu_2
				jne od_2_2
				
				spr_2:
				cmp bl,0
				je DALEJ_GRA
				jne dwu_cyfrowa
				
				
					od_2_2:
						dec byte ptr si[1]
						jmp spr_2
				
					od_dwu_2:
						;KONIEC GRY
						cmp byte ptr si[0],30H
						je KONIEC_GRY
						jne od_1_2
							
						od_1_2:
						dec byte ptr si[0]
						mov byte ptr si[1],39H
						jmp spr_2
				
				
	
			jedno_cyfrowa:
			
				dec bl
				cmp byte ptr si[0],30H
				je KONIEC_GRY
				jne odejmij_od1
				
				spr_1:
				cmp bl,0
				je DALEJ_GRA
				jne jedno_cyfrowa
				
				odejmij_od1:
				dec byte ptr si[0]
				jmp spr_1
				

;jesli zwroce dl 55 to koniec gry
;jesli nie to jeszcze jest czas
KONIEC_GRY:
mov dl,55D
jmp wyjdz_p4

DALEJ_GRA:
mov dl,1D
jmp wyjdz_p4


wyjdz_p4:
RET
odejmij_wartosc ENDP
;--------------------------------------------
losuj_random_offset PROC NEAR

;Opis: Funkcja służy do losowania offsetow, odczytuje ze zmiennej odpowiednio liczby wykorzystywane do losowania offestów.

	poczatek_los:
	mov cx,0
	;dostaje od bl np. 2, czas czytany jest ze zmiennej i offestu 2 do dl'a max 99 wartosc
	;Operacje na milisekundach
	mov si,offset czas_ostatni
	mov dl,si[bx]
	PUSH BX
	add cx,dx
	add cx,dx
	add cx,dx
	add cx,dx
	add cx,dx;5x99=495
	mov bx,0
	mov bx,cx;w bx max 495
	add cx,bx;teraz dodaje o 495
	add cx,bx;1500 ok.
	add cx,bx;ok 2462 max
	add cx,bx;ok 2957
	add cx,bx;ok 3452
	;Teraz sekunda
	POP BX
	mov dx,0
	mov dl,si[bx+1];w dl max 60
	add cx,dx
	add cx,dx
	add cx,dx
	add cx,dx
	add cx,dx;
	add cx,dx
	add cx,dx
	add cx,dx
	add cx,dx
	add cx,dx;10x60=600;RAZZEM 4052 max.
	
	add cx,01E2H;zaczyna od 482
	PUSH BX
	mov bx,0
	
	jmp spr0_los
	
	poczatek_losb:
	jmp poczatek_los
	
	spr0_los:
	;spr parzystosc
	mov dx,0
	mov ax,cx
	mov bx,0002H
	div bx;ax to liczba do podzielenia bx to dzielnik w dx reszta
	POP BX
	cmp dx,0
	je spr1_los
	jne zmniejsz_o_bit
	
	zmniejsz_o_bit:
	dec cx
	jmp spr1_los
	
	
	;spr czy nie za malo by sie odwolac
	spr1_los:
		cmp cx,01E0H
		jnb spr2_los
		jb add_to_cx
	;spr czy nie za duzo
			spr2_los:
				cmp cx,4000D;
				jb wyjdz_z_los
				jnb reduce_cx;
	add_to_cx:
	add cx,01E2H
	jmp wyjdz_z_los
	reduce_cx:
	add cx,-2500D
	jmp wyjdz_z_los
	;CH-godzina CL-Minuta DH-Sekunda DL-1/100sec
	wyjdz_z_los:
	mov ax,0
	mov dx,0
RET
losuj_random_offset ENDP
;---------------
delay_sth PROC NEAR

;Opis: Funkcja służy do opóźnienia gry, by można było poprawnie wylosować liczby(offsety).

	mov ax,0
	mov bx,0
	mov dx,0
	mov ah,2Ch ;pobranie czasu proc.;
	int 21h;
	;CH-godzina CL-Minuta DH-Sekunda DL-1/100sec
	mov dh,0
	PUSH DX
	petla7:
	mov ah,2Ch ;pobranie czasu proc.
	int 21h;
	mov dh,0
	
	POP bx
	PUSH BX
	PUSH dx
	sub dl,bl;
	
	cmp dl,cl;Ile mili
	jnb koniec_delay_przed

	POP DX
	sub bl,dl
	cmp bl,cl;Ile mili
	jnb koniec_delay
	jb petla7
	
	
	koniec_delay_przed:
	POP CX
	jmp koniec_delay
	
	koniec_delay:
	POP CX
	mov ax,0
	mov bx,0
	mov cx,0
	mov dx,0
RET
delay_sth ENDP
;------------------------------------------------------------
wykonaj_ruch PROC NEAR

;Opis: Funkcja służy do obsługi sterowania ludzikiem.

		cmp bl,0
		je pm_gora
		
		cmp bl,1
		je pm_prawo
		
		cmp bl,2
		je pm_dol
		
		cmp bl,3
		je pm_lewo
		
		pm_gora:
		add cx,-160
		jmp dalejwykonaj_ruch
		
		pm_prawo:
		add cx,2
		jmp dalejwykonaj_ruch
		
		pm_dol:
		add cx,160
		jmp dalejwykonaj_ruch
		
		pm_lewo:
		add cx,-2
		jmp dalejwykonaj_ruch
		
		dalejwykonaj_ruch:
		
		mov ax,seg ekran
		mov es,ax
	;---
	;Usuwam kolory byle
		mov si,offset cord_p
		mov bx,si[0]
		
		mov ek[bx-4],00H;kolor;DOLNA PODSTAWA
		mov ek[bx-2],00H;kolor
		mov ek[bx],00H;kolor
		mov ek[bx+2],00H;kolor
		mov ek[bx+4],00H;kolor
		
	;Dodaje nowe
		mov ax,bx
		add bx,cx
		cmp bx,640
		jb wracaj_ruch
		
		cmp bx,3840
		jnb wracaj_ruch
		jb rysuj_ruch
		wracaj_ruch:
		mov bx,ax
		jmp rysuj_ruch
		
		
		rysuj_ruch:
	;Aktualizacja
		mov si[0],bx
		PUSH BX
		
	
		
		mov ek[bx-4],0E0H;kolor;DOLNA PODSTAWA
		mov ek[bx-2],0E0H;kolor
		mov ek[bx],0E0H;kolor
		mov ek[bx+2],0E0H;kolor
		mov ek[bx+4],0E0H;kolor
		
	
		
	;--
	;Usuwam kolory byle
		mov si,offset cord_w
		mov bx,si[0]
		
		mov ek[bx-2],00H;GORNA PODSTAWA
		mov ek[bx],00H
		mov ek[bx+2],00H
		
	;Dodaje nowe
	
		mov ax,bx
		add bx,cx
		cmp bx,480
		jb wracaj_ruch2
		
		cmp bx,3680
		jnb wracaj_ruch2
		jb rysuj_ruch2
		wracaj_ruch2:
		mov bx,ax
		jmp rysuj_ruch2
		rysuj_ruch2:
		;Aktualizacja
		mov si[0],bx
		
		mov ek[bx-2],78H;GORNA PODSTAWA
		mov ek[bx],78H
		mov ek[bx+2],78H
		
	;--
	
	
	;Usuwam kolory byle
		mov si,offset cord_w2
		mov bx,si[0]
		
		mov ek[bx-2],00H;GORNA PODSTAWA
		mov ek[bx],00H
		mov ek[bx+2],00H
		
	;Dodaje nowe
	
		mov ax,bx
		add bx,cx
		cmp bx,800
		jb wracaj_ruch23
		
		cmp bx,4000
		jnb wracaj_ruch23
		jb rysuj_ruch23
		wracaj_ruch23:
		mov bx,ax
		jmp rysuj_ruch23
		rysuj_ruch23:
		;Aktualizacja
		mov si[0],bx
		
		mov ek[bx-2],78H;GORNA PODSTAWA
		mov ek[bx],78H
		mov ek[bx+2],78H
	
	
	
	;---	
	;Dodanie dolnej podstawy fix
		POP BX
		
		mov ek[bx-2],78H;kolor
		mov ek[bx],78H;kolor
		mov ek[bx+2],78H;kolor
		
		
		mov dx,offset tpustepole;wyzerowac sie nie da a w dx musi cos przechowac, niech wiec przechowa tylko dolara
		mov ah,09h
		int 21h
		
		
		mov ax,0
		mov bx,0
		mov cx,0
		mov dx,0
		

RET
wykonaj_ruch ENDP
detekcja_kolizji PROC NEAR

;Opis: Funkcja służy do obsługi kolizji ludzika z liczbami. Otrzymuje SI(współrzedne srodka ludzika) jako parametr.

			PUSH SI
			mov di,0
			petla8:
	
			mov bx,offset_liczb[di]
			POP SI
			PUSH SI
			dec si;bo to kolory...
			mov ax,si
			cmp bx,ax;przyrownuje cordy gory do liczby 1
			je dodaj_x
			
			
			sub ax,2;prawe skrzydlo
			cmp bx,ax
			je dodaj_x
			
			add ax,4;lewe skrzydlo
			cmp bx,ax
			je dodaj_x
			
			add di,2
			cmp di,18
			je wyjdz_p8
			jne petla8
			
		petla8b:
		jmp petla8
		dodaj_x:
		mov ek[bx],20H
		mov offset_liczb[di],0000H;Zerowanie by nie bylo redunddancji
		
		
		PUSH AX
		PUSH BX
		mov dx,0
		mov cx,0
		mov ax,0
		mov bx,0
		mov ax,di
		mov bx,0002H
		div bx;ax to liczba do podzielenia bx to dzielnik w dx reszta
		mov ch,0
		mov cl,al
		POP BX
		POP AX
		add cl,1;bo bylo od 0 do 8

		;w cl mam ile ma sie powtorzyc
		PUSH BX
		mov bx,0
		mov si,offset sumau
		petla9:
		mov bl,1D
		call dodaj_wartosc
		sub cl,1
		cmp cl,0
		je koniec_p9
		jne petla9
		
		koniec_p9:
		POP BX
		
		;Tutaj oblcizy sume z petli wykonujaca sie x razy tz. procedura
		
		mov si,offset sumau
		mov dl,37
		mov dh,1
		mov tkolor[0],21H
		call wyswietl_proc
		
		add di,2
		cmp di,18
		je wyjdz_p8
		jne petla8b
		
		wyjdz_p8:
			POP SI
			mov ax,0
			mov bx,0
			mov cx,0
			mov si,0
			mov di,0

RET
detekcja_kolizji ENDP


dodaj_wartosc PROC NEAR

;Opis: Funkcja służy dodawania punktow w formie jednosci, dziesietnej i setek.

	;spr czy 3 czy 2 cyforwa
	mov bh,si[1]
	cmp byte ptr bh,0DH
	je jedno_cyfrowa_s
	
	mov bh,si[2]
	cmp byte ptr bh,0DH
	je dwu_chyba_cyfrowa_s
	jne trzy_cyfrowa_s
		
		dwu_chyba_cyfrowa_s:
		mov bh,si[1]
		cmp byte ptr bh,0DH;mowie jaki typ ma...
		je jedno_cyfrowa_s
		jne dwu_cyfrowa_s
		
	
			trzy_cyfrowa_s:
			
				dec bl
				cmp byte ptr si[2],39H
				je od_dwu_3_s
				jne od_3_s
				
				spr_3_s:
				cmp bl,0
				je DALEJ_GRA_s
				jne trzy_cyfrowa_s
				
				
					od_3_s:
						inc byte ptr si[2]
						jmp spr_3_s
				
					od_dwu_3_s:
					
						cmp byte ptr si[1],39H
						je od_jed_3_s
						jne od_2_s
							
						od_jed_3_s:
							;KONIEC GRY
							cmp byte ptr si[0],39H
							je KONIEC_GRY_s
							jne od_1_s
							
							od_1_s:
							inc byte ptr si[0]
							mov byte ptr si[1],30H
							mov byte ptr si[2],30H
							jmp spr_3_s
							
						od_2_s:
							inc byte ptr si[1]
							mov byte ptr si[2],30H
							jmp spr_3_s
				
			dwu_cyfrowa_s:
				
				dec bl
				cmp byte ptr si[1],39H
				je od_dwu_2_s
				jne od_2_2_s
				
				spr_2_s:
				cmp bl,0
				je DALEJ_GRA_s
				jne dwu_cyfrowa_s
				
				
					od_2_2_s:
						inc byte ptr si[1]
						jmp spr_2_s
				
					od_dwu_2_s:
						;KONIEC GRY
						cmp byte ptr si[0],39H
						je KONIEC_GRY_s
						jne od_1_2_s
							
						od_1_2_s:
						inc byte ptr si[0]
						mov byte ptr si[1],30H
						jmp spr_2_s
				
				
	
			jedno_cyfrowa_s:
			
				dec bl
				cmp byte ptr si[0],39H
				je KONIEC_GRY_s
				jne dodaj_od1
				
				spr_1_s:
				cmp bl,0
				je DALEJ_GRA_s
				jne jedno_cyfrowa_s
				
				dodaj_od1:
				inc byte ptr si[0]
				jmp spr_1_s
				

;jesli zwroce dl 55 to koniec gry
;jesli nie to jeszcze jest czas
KONIEC_GRY_s:
mov dl,55D
jmp wyjdz_p4_s

DALEJ_GRA_s:
mov dl,1D
jmp wyjdz_p4_s


wyjdz_p4_s:
RET
dodaj_wartosc ENDP


;----------
main ends
end start
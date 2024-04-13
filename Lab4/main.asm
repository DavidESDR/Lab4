TITLE main Lab4		(main.asm)

; Description	: Program stores a list of students and grades, sorts them, and assigns a letter grade.
; Author		: David Gorzynski
; Created		: 4/8/2024
; Revisions		: None
; Last Modified	: 4/12/2024

.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword
DumpRegs PROTO

INCLUDE Macros.inc
INCLUDE Irvine32.inc

.data

; A list of grades mapped to a student's name
;	To simplify swaping elements, strings are fixed at a length of 8,
;	though this can be changed to any length as 255 is used as a stop byte.
student_grade_map	BYTE	88, "Mark    ", 255,
							79, "Jacob   ", 255,
							95, "Rodney  ", 255,
							98, "Isabella", 255,
							74, "Duke    ", 255,
							57, "Peter   ", 255,
							82, "Rachel  ", 255,
							91, "John    ", 255,
							65, "Markus  ", 255,
							12, "Kate    ", 255

; Length of a student-grade entry in bytes
entry_length		DWORD	10
entry_lengthA		BYTE	10

; Array storing the number of As, Bs, Cs, Ds, and Fs found in the list above
grade_counts		BYTE	0, 0, 0, 0, 0

; Iterators
iter_a				BYTE	0
iter_b				BYTE	0

; Buffers
buff_a				BYTE	0
buff_b				BYTE	0
buff_c				DWORD	0
buff_d				BYTE	0

.code
main PROC
	
	;mov DX, 0	; Iterator for min entry slot
	;TestLoop:
		;movzx EAX, DX
		;movzx EAX, student_grade_map[EAX]
		;call WriteDec
		;mWrite <" ",0dh,0ah>
		;add DX, entry_lengthA
		;cmp DX, SIZEOF student_grade_map
		;jne TestLoop


	;mWrite <"This program can be assembled to run ",0dh,0ah>

	;mov AL, 'H'
	;jmp WriteChar

	;mov EAX, entry_length
	;call WriteDec

	Sort:
	; Initalize registers
	mov EAX, 0	; Iterator for min entry slot
	mov EBX, 0	; Iterator for selected min entry
	mov ECX, 0	; Buffer A
	mov EDX, 0	; Buffer B

	; Loop from 0 to 9, using SelectLoop to find the largest entry, and swapping it to put it in decending order
	SortLoop:
		; Set EDX to ECX plus one so we select from unsorted entry
		mov CL, iter_a
		mov iter_b, CL
		mov CL, entry_lengthA
		add iter_b, CL
		movzx EAX, iter_a
		
		; Find the next largest entry from the remaining unsorted entries
		SelectLoop:
			; Compare the current selection to the current SelectLoop index
			mov CL, student_grade_map[EBX]
			movzx EDX, iter_b
			mov DL, student_grade_map[EDX]
			cmp CL, DL

			; If the currently selected entry has a lower grade than the entry being checked, change the selection
			jb ChangeSelection

			jae SelectionLoopInc

			ChangeSelection:

			movzx EBX, iter_b

			SelectionLoopInc:
			mov CL, entry_lengthA
			add iter_b, CL
			cmp iter_b, SIZEOF student_grade_map

			jne SelectLoop
		
		; Reset seccond loop counter
		mov iter_b, 0
		
		cmp EAX, EBX
		je SkipSwap

		; Swaps the entries found at EAX and EBX
		Swap:
		SwapLoop:
			mov CL, student_grade_map[EAX]	; Store byte A in a temporary register
			mov DL, student_grade_map[EBX]	; Store byte B in a temporary register
			mov student_grade_map[EAX], DL	; Swap byte A for byte B
			mov student_grade_map[EBX], CL	; Swap byte B for byte A
			inc EAX
			inc EBX
			mov CL, student_grade_map[EAX]

			cmp CL, 255						; Check for stop bit
			jne SwapLoop
		jmp IncLoop
		
		SkipSwap:
		add EAX, entry_length
		add EBX, entry_length

		IncLoop:

		; Incrament EAX to point at the grade of the next entry
		inc EAX
		dec EBX
		
		mov CL, entry_lengthA
		add iter_a, CL
		mov CL, SIZEOF student_grade_map
		sub CL, entry_lengthA
		sub CL, entry_lengthA
		cmp iter_a, CL
		jne SortLoop

	Grade:

	; Initalize registers
	mov EAX, 0	; Iterator for the loop
	mov EBX, 0	; Grade assignment iterator, starts at A, ends at F
	mov CL, 0	; Current grade being checked
	mov DL, 0	; Letter grade threashold

	GradeLoop:
		mov CL, student_grade_map[EAX]

		; Loop through potential grades, stop at F
		CheckLoop:
			cmp CL, DL	; Compare student grade with letter grade
			ja Assign	; If the student's grade is above the letter grade's threashold, incrament that letter grade's count
			sub DL, 10	; If not, go to the next letter grade
			inc EBX
			cmp DL, 59	; Check if the letter grade is F
			je Assign
			
		Assign:
		mov buff_a, AL
		mov buff_b, BL

		mov AL, buff_a
		call WriteDec
		mWrite <" ",0dh,0ah>
		
		mov AL, buff_b
		call WriteDec

		mWrite <" ",0dh,0ah>
		mWrite <" ",0dh,0ah>
		mov AL, buff_a
		mov BL, buff_b

		add grade_counts[EBX], 1

		add EAX, entry_length
		cmp EAX, SIZEOF student_grade_map
		jne GradeLoop

main ENDP

END main
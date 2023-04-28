/***** hpda:net.sources / homxb!gemini /  1:58 am  Apr  1, 1986*/
/*	EVERBODY:	Please read "APOLOGY" below. -rick 01/06/85
 *			See introduction in net.arch, or net.micro
 *
 *	"DHRYSTONE" Benchmark Program
 *
 *	Version:	C/1.1, 12/01/84
 *
 *	Date:		PROGRAM updated 01/06/86, RESULTS updated 03/31/86
 *
 *	Author:		Reinhold P. Weicker,  CACM Vol 27, No 10, 10/84 pg. 1013
 *			Translated from ADA by Rick Richardson
 *			Every method to preserve ADA-likeness has been used,
 *			at the expense of C-ness.
 *
 *	Compile:	cc -O dry.c -o drynr			: No registers
 *                      cc -O -DREG=register dry.c -o dryr      : Registers
 *
 *	Defines:	Defines are provided for old C compiler's
 *			which don't have enums, and can't assign structures.
 *			The time(2) function is library dependant; Most
 *			return the time in seconds, but beware of some, like
 *			Aztec C, which return other units.
 *			The LOOPS define is initially set for 50000 loops.
 *			If you have a machine with large integers and is
 *			very fast, please change this number to 500000 to
 *			get better accuracy.  Please select the way to
 *			measure the execution time using the TIME define.
 *			For single user machines, time(2) is adequate. For
 *			multi-user machines where you cannot get single-user
 *			access, use the times(2) function.  If you have
 *			neither, use a stopwatch in the dead of night.
 *			Use a "printf" at the point marked "start timer"
 *			to begin your timings. DO NOT use the UNIX "time(1)"
 *			command, as this will measure the total time to
 *			run this program, which will (erroneously) include
 *			the time to malloc(3) storage and to compute the
 *			time it takes to do nothing.
 *
 *	Run:		drynr; dryr
 *
 *	Results:	If you get any new machine/OS results, please send to:
 *
 *				ihnp4!castor!pcrat!rick
 *
 *			and thanks to all that do.  Space prevents listing
 *			the names of those who have provided some of these
 *			results.  I'll be forwarding these results to
 *			Rheinhold Weicker.
 *
 *	Note:		I order the list in increasing performance of the
 *			"with registers" benchmark.  If the compiler doesn't
 *			provide register variables, then the benchmark
 *			is the same for both REG and NOREG.
 *
 *	PLEASE:		Send complete information about the machine type,
 *			clock speed, OS and C manufacturer/version.  If
 *			the machine is modified, tell me what was done.
 *			On UNIX, execute uname -a and cc -V to get this info.
 *
 *	80x8x NOTE:	80x8x benchers: please try to do all memory models
 *			for a particular compiler.
 *
 *	APOLOGY (1/30/86):
 *		Well, I goofed things up!  As pointed out by Haakon Bugge,
 *		the line of code marked "GOOF" below was missing from the
 *		Dhrystone distribution for the last several months.  It
 *		*WAS* in a backup copy I made last winter, so no doubt it
 *		was victimized by sleepy fingers operating vi!
 *
 *		The effect of the line missing is that the reported benchmarks
 *		are 15% too fast (at least on a 80286).  Now, this creates
 *		a dilema - do I throw out ALL the data so far collected
 *		and use only results from this (corrected) version, or
 *		do I just keep collecting data for the old version?
 *
 *		Since the data collected so far *is* valid as long as it
 *		is compared with like data, I have decided to keep
 *		TWO lists- one for the old benchmark, and one for the
 *		new.  This also gives me an opportunity to correct one
 *		other error I made in the instructions for this benchmark.
 *		My experience with C compilers has been mostly with
 *		UNIX 'pcc' derived compilers, where the 'optimizer' simply
 *		fixes sloppy code generation (peephole optimization).
 *		But today, there exist C compiler optimizers that will actually
 *		perform optimization in the Computer Science sense of the word,
 *		by removing, for example, assignments to a variable whose
 *		value is never used.  Dhrystone, unfortunately, provides
 *		lots of opportunities for this sort of optimization.
 *
 *		I request that benchmarkers re-run this new, corrected
 *		version of Dhrystone, turning off or bypassing optimizers
 *		which perform more than peephole optimization.  Please
 *		indicate the version of Dhrystone used when reporting the
 *		results to me.
 *		
 * RESULTS BEGIN HERE
 *
 *----------------DHRYSTONE VERSION 1.1 RESULTS BEGIN--------------------------
 *
 * MACHINE	MICROPROCESSOR	OPERATING	COMPILER	DHRYSTONES/SEC.
 * TYPE				SYSTEM				NO REG	REGS
 * --------------------------	------------	-----------	---------------
 * Apple IIe	65C02-1.02Mhz	DOS 3.3		Aztec CII v1.05i  37	  37
 * -		Z80-2.5Mhz	CPM-80 v2.2	Aztec CII v1.05g  91	  91
 * -		8086-8Mhz	RMX86 V6	Intel C-86 V2.0	 197	 203LM??
 * IBM PC/XT	8088-4.77Mhz	COHERENT 2.3.43	Mark Wiiliams	 259	 275
 * -		8086-8Mhz	RMX86 V6	Intel C-86 V2.0	 287	 304 ??
 * Fortune 32:16 68000-6Mhz	V7+sys3+4.1BSD  cc		 360	 346
 * PDP-11/34A	w/FP-11C	UNIX V7m	cc		 406	 449
 * Macintosh512	68000-7.7Mhz	Mac ROM O/S	DeSmet(C ware)	 625	 625
 * VAX-11/750	w/FPA		UNIX 4.2BSD	cc		 831	 852
 * DataMedia 932 68000-10Mhz	UNIX sysV	cc		 837	 888
 * Plexus P35	68000-12.5Mhz	UNIX sysIII	cc		 835	 894
 * ATT PC7300	68010-10Mhz	UNIX 5.0.3	cc		 973	1034
 * Compaq II	80286-8Mhz	MSDOS 3.1	MS C 3.0 	1086	1140 LM
 * IBM PC/AT    80286-7.5Mhz    Venix/286 SVR2  cc              1159    1254 *15
 * Compaq II	80286-8Mhz	MSDOS 3.1	MS C 3.0 	1190	1282 MM
 * MicroVAX II	-		Mach/4.3	cc		1361	1385
 * DEC uVAX II	-		Ultrix-32m v1.1	cc		1385	1399
 * Compaq II	80286-8Mhz	MSDOS 3.1	MS C 3.0 	1351	1428
 * VAX 11/780	-		UNIX 4.2BSD	cc		1417	1441
 * VAX-780/MA780		Mach/4.3	cc		1428	1470
 * VAX 11/780	-		UNIX 5.0.1	cc 4.1.1.31	1650	1640
 * Ridge 32C V1	-		ROS 3.3		Ridge C (older)	1628	1695
 * Gould PN6005	-		UTX 1.1c+ (4.2)	cc		1732	1884
 * Gould PN9080	custom ECL	UTX-32 1.1C	cc		4745	4992
 * VAX-784	-		Mach/4.3	cc		5263	5555 &4
 * VAX 8600	-		4.3 BSD		cc		6329	6423
 * Amdahl 5860	-		UTS sysV	cc 1.22	       28735   28846
 * IBM3090/200	-		?		?	       31250   31250
 *
 *
 *----------------DHRYSTONE VERSION 1.0 RESULTS BEGIN--------------------------
 *
 * MACHINE	MICROPROCESSOR	OPERATING	COMPILER	DHRYSTONES/SEC.
 * TYPE				SYSTEM				NO REG	REGS
 * --------------------------	------------	-----------	---------------
 * Commodore 64	6510-1MHz	C64 ROM		C Power 2.8	  36	  36
 * HP-110	8086-5.33Mhz	MSDOS 2.11	Lattice 2.14	 284	 284
 * IBM PC/XT	8088-4.77Mhz	PC/IX		cc		 271	 294
 * CCC 3205	-		Xelos(SVR2) 	cc		 558	 592
 * Perq-II	2901 bitslice	Accent S5c 	cc (CMU)	 301	 301
 * IBM PC/XT	8088-4.77Mhz	COHERENT 2.3.43	MarkWilliams cc  296	 317
 * Cosmos	68000-8Mhz	UniSoft		cc		 305	 322
 * IBM PC/XT	8088-4.77Mhz	Venix/86 2.0	cc		 297	 324
 * DEC PRO 350  11/23           Venix/PRO SVR2  cc               299     325
 * IBM PC	8088-4.77Mhz	MSDOS 2.0	b16cc 2.0	 310	 340
 * PDP11/23	11/23           Venix (V7)      cc               320     358
 * Commodore Amiga		?		Lattice 3.02	 368	 371
 * PC/XT        8088-4.77Mhz    Venix/86 SYS V  cc               339     377
 * IBM PC	8088-4.77Mhz	MSDOS 2.0	CI-C86 2.20M	 390	 390
 * IBM PC/XT	8088-4.77Mhz	PCDOS 2.1	Wizard 2.1	 367	 403
 * IBM PC/XT	8088-4.77Mhz	PCDOS 3.1	Lattice 2.15	 403	 403 @
 * Colex DM-6	68010-8Mhz	Unisoft SYSV	cc		 378	 410
 * IBM PC	8088-4.77Mhz	PCDOS 3.1	Datalight 1.10	 416	 416
 * IBM PC	NEC V20-4.77Mhz	MSDOS 3.1	MS 3.1 		 387	 420
 * IBM PC/XT	8088-4.77Mhz	PCDOS 2.1	Microsoft 3.0	 390	 427
 * IBM PC	NEC V20-4.77Mhz	MSDOS 3.1	MS 3.1 (186) 	 393	 427
 * PDP-11/34	-		UNIX V7M	cc		 387	 438
 * IBM PC	8088, 4.77mhz	PC-DOS 2.1	Aztec C v3.2d	 423	 454
 * Tandy 1000	V20, 4.77mhz	MS-DOS 2.11	Aztec C v3.2d	 423	 458
 * Tandy TRS-16B 68000-6Mhz	Xenix 1.3.5	cc		 438	 458
 * PDP-11/34	-		RSTS/E		decus c		 438	 495
 * Onyx C8002	Z8000-4Mhz	IS/1 1.1 (V7)	cc		 476	 511
 * Tandy TRS-16B 68000-6Mhz	Xenix 1.3.5	Green Hills	 609	 617
 * DEC PRO 380  11/73           Venix/PRO SVR2  cc               577     628
 * FHL QT+	68000-10Mhz	Os9/68000	version 1.3	 603	 649 FH
 * Apollo DN550	68010-?Mhz	AegisSR9/IX	cc 3.12		 666	 666
 * HP-110	8086-5.33Mhz	MSDOS 2.11	Aztec-C		 641	 676 
 * ATT PC6300	8086-8Mhz	MSDOS 2.11	b16cc 2.0	 632	 684
 * IBM PC/AT	80286-6Mhz	PCDOS 3.0	CI-C86 2.1	 666	 684
 * Tandy 6000	68000-8Mhz	Xenix 3.0	cc		 694	 694
 * IBM PC/AT	80286-6Mhz	Xenix 3.0	cc		 684	 704 MM
 * Macintosh	68000-7.8Mhz 2M	Mac Rom		Mac C 32 bit int 694	 704
 * Macintosh	68000-7.7Mhz	-		MegaMax C 2.0	 661	 709
 * Macintosh512	68000-7.7Mhz	Mac ROM O/S	DeSmet(C ware)	 714	 714
 * IBM PC/AT	80286-6Mhz	Xenix 3.0	cc		 704	 714 LM
 * Codata 3300	68000-8Mhz	UniPlus+ (v7)	cc		 678	 725
 * WICAT MB	68000-8Mhz	System V	WICAT C 4.1	 585	 731 ~
 * Cadmus 9000	68010-10Mhz	UNIX		cc		 714	 735
 * AT&T 6300    8086-8Mhz       Venix/86 SVR2   cc               668     743
 * Cadmus 9790	68010-10Mhz 1MB	SVR0,Cadmus3.7	cc		 720	 747
 * NEC PC9801F	8086-8Mhz	PCDOS 2.11	Lattice 2.15	 768	  -  @
 * ATT PC6300	8086-8Mhz	MSDOS 2.11	CI-C86 2.20M	 769	 769
 * Burroughs XE550 68010-10Mhz	Centix 2.10	cc		 769	 769 CT1
 * EAGLE/TURBO  8086-8Mhz       Venix/86 SVR2   cc               696     779
 * ALTOS 586	8086-10Mhz	Xenix 3.0b	cc 		 724	 793
 * DEC 11/73	J-11 micro	Ultrix-11 V3.0	cc		 735	 793
 * ATT 3B2/300	WE32000-?Mhz	UNIX 5.0.2	cc		 735	 806
 * Apollo DN320	68010-?Mhz	AegisSR9/IX	cc 3.12		 806	 806
 * IRIS-2400	68010-10Mhz	UNIX System V	cc		 772	 829
 * Atari 520ST  68000-8Mhz      TOS             DigResearch      839     846
 * IBM PC/AT	80286-6Mhz	PCDOS 3.0	MS 3.0(large)	 833	 847 LM
 * WICAT MB	68000-8Mhz	System V	WICAT C 4.1	 675	 853 S~
 * VAX 11/750	-		Ultrix 1.1	4.2BSD cc	 781	 862
 * CCC  7350A	68000-8MHz	UniSoft V.2	cc		 821	 875
 * VAX 11/750	-		UNIX 4.2bsd	cc		 862	 877
 * Fast Mac	68000-7.7Mhz	-		MegaMax C 2.0	 839	 904 +
 * IBM PC/XT	8086-9.54Mhz	PCDOS 3.1	Microsoft 3.0	 833	 909 C1
 * DEC 11/44			Ultrix-11 V3.0	cc		 862	 909
 * Macintosh	68000-7.8Mhz 2M	Mac Rom		Mac C 16 bit int 877	 909 S
 * CCC 3210	-		Xelos R01(SVR2)	cc		 849	 924
 * CCC 3220	-               Ed. 7 v2.3      cc		 892	 925
 * IBM PC/AT	80286-6Mhz	Xenix 3.0	cc -i		 909	 925
 * AT&T 6300	8086, 8mhz	MS-DOS 2.11	Aztec C v3.2d	 862	 943
 * IBM PC/AT	80286-6Mhz	Xenix 3.0	cc		 892	 961
 * VAX 11/750	w/FPA		Eunice 3.2	cc		 914	 976
 * IBM PC/XT	8086-9.54Mhz	PCDOS 3.1	Wizard 2.1	 892	 980 C1
 * IBM PC/XT	8086-9.54Mhz	PCDOS 3.1	Lattice 2.15	 980	 980 C1
 * Plexus P35	68000-10Mhz	UNIX System III cc		 984	 980
 * PDP-11/73	KDJ11-AA 15Mhz	UNIX V7M 2.1	cc		 862     981
 * VAX 11/750	w/FPA		UNIX 4.3bsd	cc		 994	 997
 * IRIS-1400	68010-10Mhz	UNIX System V	cc		 909	1000
 * IBM PC/AT	80286-6Mhz	Venix/86 2.1	cc		 961	1000
 * IBM PC/AT	80286-6Mhz	PCDOS 3.0	b16cc 2.0	 943	1063
 * Zilog S8000/11 Z8001-5.5Mhz	Zeus 3.2	cc		1011	1084
 * NSC ICM-3216 NSC 32016-10Mhz	UNIX SVR2	cc		1041	1084
 * IBM PC/AT	80286-6Mhz	PCDOS 3.0	MS 3.0(small)	1063	1086
 * VAX 11/750	w/FPA		VMS		VAX-11 C 2.0	 958	1091
 * Stride	68000-10Mhz	System-V/68	cc		1041	1111
 * Plexus P/60  MC68000-12.5Mhz	UNIX SYSIII	Plexus		1111	1111
 * ATT PC7300	68010-10Mhz	UNIX 5.0.2	cc		1041	1111
 * CCC 3230	-		Xelos R01(SVR2)	cc		1040	1126
 * Stride	68000-12Mhz	System-V/68	cc		1063	1136
 * IBM PC/AT    80286-6Mhz      Venix/286 SVR2  cc              1056    1149
 * Plexus P/60  MC68000-12.5Mhz	UNIX SYSIII	Plexus		1111	1163 T
 * IBM PC/AT	80286-6Mhz	PCDOS 3.0	Datalight 1.10	1190	1190
 * ATT PC6300+	80286-6Mhz	MSDOS 3.1	b16cc 2.0	1111	1219
 * IBM PC/AT	80286-6Mhz	PCDOS 3.1	Wizard 2.1	1136	1219
 * Sun2/120	68010-10Mhz	Sun 4.2BSD	cc		1136	1219
 * IBM PC/AT	80286-6Mhz	PCDOS 3.0	CI-C86 2.20M	1219	1219
 * WICAT PB	68000-8Mhz	System V	WICAT C 4.1	 998	1226 ~
 * MASSCOMP 500	68010-10MHz	RTU V3.0	cc (V3.2)	1156	1238
 * Alliant FX/8 IP (68012-12Mhz) Concentrix	cc -ip;exec -i 	1170	1243 FX
 * Cyb DataMate	68010-12.5Mhz	Uniplus 5.0	Unisoft cc	1162	1250
 * PDP 11/70	-		UNIX 5.2	cc		1162	1250
 * IBM PC/AT	80286-6Mhz	PCDOS 3.1	Lattice 2.15	1250	1250
 * IBM PC/AT	80286-7.5Mhz	Venix/86 2.1	cc		1190	1315 *15
 * Sun2/120	68010-10Mhz	Standalone	cc		1219	1315
 * Intel 380	80286-8Mhz	Xenix R3.0up1	cc		1250	1315 *16
 * Sequent Balance 8000	NS32032-10MHz	Dynix 2.0	cc	1250	1315 N12
 * IBM PC/DSI-32 32032-10Mhz	MSDOS 3.1	GreenHills 2.14	1282	1315 C3
 * ATT 3B2/400	WE32100-?Mhz	UNIX 5.2	cc		1315	1315
 * CCC 3250XP	-		Xelos R01(SVR2)	cc		1215	1318
 * IBM PC/RT 032 RISC(801?)?Mhz BSD 4.2         cc              1248    1333 RT
 * DG MV4000	-		AOS/VS 5.00	cc		1333	1333
 * IBM PC/AT	80286-8Mhz	Venix/86 2.1	cc		1275	1380 *16
 * IBM PC/AT	80286-6Mhz	MSDOS 3.0	Microsoft 3.0	1250	1388
 * ATT PC6300+	80286-6Mhz	MSDOS 3.1	CI-C86 2.20M	1428	1428
 * COMPAQ/286   80286-8Mhz      Venix/286 SVR2  cc              1326    1443
 * IBM PC/AT    80286-7.5Mhz    Venix/286 SVR2  cc              1333    1449 *15
 * WICAT PB	68000-8Mhz	System V	WICAT C 4.1	1169	1464 S~
 * Tandy II/6000 68000-8Mhz	Xenix 3.0	cc      	1384	1477
 * MicroVAX II	-		Mach/4.3	cc		1513	1536
 * WICAT MB	68000-12.5Mhz	System V	WICAT C 4.1	1246	1537 ~
 * IBM PC/AT    80286-9Mhz      SCO Xenix V     cc              1540    1556 *18
 * Cyb DataMate	68010-12.5Mhz	Uniplus 5.0	Unisoft cc	1470	1562 S
 * VAX 11/780	-		UNIX 5.2	cc		1515	1562
 * MicroVAX-II	-		-		-		1562	1612
 * VAX-780/MA780		Mach/4.3	cc		1587	1612
 * VAX 11/780	-		UNIX 4.3bsd	cc		1646	1662
 * Apollo DN660	-		AegisSR9/IX	cc 3.12		1666	1666
 * ATT 3B20	-		UNIX 5.2	cc		1515	1724
 * NEC PC-98XA	80286-8Mhz	PCDOS 3.1	Lattice 2.15	1724	1724 @
 * HP9000-500	B series CPU	HP-UX 4.02	cc		1724	-
 * Ridge 32C V1	-		ROS 3.3		Ridge C (older)	1776	-
 * IBM PC/STD	80286-8Mhz	MSDOS 3.0 	Microsoft 3.0	1724	1785 C2
 * WICAT MB	68000-12.5Mhz	System V	WICAT C 4.1	1450	1814 S~
 * WICAT PB	68000-12.5Mhz	System V	WICAT C 4.1	1530	1898 ~
 * DEC-2065	KL10-Model B	TOPS-20 6.1FT5	Port. C Comp.	1937	1946
 * Gould PN6005	-		UTX 1.1(4.2BSD)	cc		1675	1964
 * DEC2060	KL-10		TOPS-20		cc		2000	2000 NM
 * Intel 310AP	80286-8Mhz	Xenix 3.0	cc		1893	2009
 * VAX 11/785	-		UNIX 5.2	cc		2083	2083
 * VAX 11/785	-		VMS		VAX-11 C 2.0	2083	2083
 * VAX 11/785	-		UNIX SVR2	cc		2123	2083
 * VAX 11/785   -               ULTRIX-32 1.1   cc		2083    2091 
 * VAX 11/785	-		UNIX 4.3bsd	cc		2135	2136
 * WICAT PB	68000-12.5Mhz	System V	WICAT C 4.1	1780	2233 S~
 * Pyramid 90x	-		OSx 2.3		cc		2272	2272
 * Pyramid 90x	FPA,cache,4Mb	OSx 2.5		cc no -O	2777	2777
 * Pyramid 90x	w/cache		OSx 2.5		cc w/-O		3333	3333
 * IBM-4341-II	-		VM/SP3		Waterloo C 1.2  3333	3333
 * IRIS-2400T	68020-16.67Mhz	UNIX System V	cc		3105	3401
 * Celerity C-1200 ?		UNIX 4.2BSD	cc		3485	3468
 * SUN 3/75	68020-16.67Mhz	SUN 4.2 V3	cc		3333	3571
 * IBM-4341	Model 12	UTS 5.0		?		3685	3685
 * SUN-3/160    68020-16.67Mhz  Sun 4.2 V3.0A   cc		3381    3764
 * Sun 3/180	68020-16.67Mhz	Sun 4.2		cc		3333	3846
 * IBM-4341	Model 12	UTS 5.0		?		3910	3910 MN
 * MC 5400	68020-16.67MHz	RTU V3.0	cc (V4.0)	3952	4054
 * Intel 386/20	80386-12.5Mhz	PMON debugger	Intel C386v0.2	4149	4386
 * NCR Tower32  68020-16.67Mhz  SYS 5.0 Rel 2.0 cc              3846	4545
 * MC 5600/5700	68020-16.67MHz	RTU V3.0	cc (V4.0)	4504	4746 %
 * Intel 386/20	80386-12.5Mhz	PMON debugger	Intel C386v0.2	4534	4794 i1
 * Intel 386/20	80386-16Mhz	PMON debugger	Intel C386v0.2	5304	5607
 * Gould PN9080	custom ECL	UTX-32 1.1C	cc		5369	5676
 * Gould 1460-342 ECL proc      UTX/32 1.1/c    cc              5342    5677 G1
 * VAX-784	-		Mach/4.3	cc		5882	5882 &4
 * Intel 386/20	80386-16Mhz	PMON debugger	Intel C386v0.2	5801	6133 i1
 * VAX 8600	-		UNIX 4.3bsd	cc		7024	7088
 * VAX 8600	-		VMS		VAX-11 C 2.0	7142	7142
 * Alliant FX/8 CE		Concentrix	cc -ce;exec -c 	6952	7655 FX
 * CCI POWER 6/32		COS(SV+4.2)	cc		7500	7800
 * CCI POWER 6/32		POWER 6 UNIX/V	cc		8236	8498
 * CCI POWER 6/32		4.2 Rel. 1.2b	cc		8963	9544
 * Sperry (CCI Power 6)		4.2BSD		cc		9345   10000
 * CRAY-X-MP/12	   105Mhz	COS 1.14	Cray C         10204   10204
 * IBM-3083	-		UTS 5.0 Rel 1	cc	       16666   12500
 * CRAY-1A	    80Mhz	CTSS		Cray C 2.0     12100   13888
 * IBM-3083	-		VM/CMS HPO 3.4	Waterloo C 1.2 13889   13889
 * Amdahl 470 V/8 		UTS/V 5.2       cc v1.23       15560   15560
 * CRAY-X-MP/48	   105Mhz	CTSS		Cray C 2.0     15625   17857
 * Amdahl 580	-		UTS 5.0 Rel 1.2	cc v1.5        23076   23076
 * Amdahl 5860	 		UTS/V 5.2       cc v1.23       28970   28970
 *
 * NOTE
 *   *   Crystal changed from 'stock' to listed value.
 *   +   This Macintosh was upgraded from 128K to 512K in such a way that
 *       the new 384K of memory is not slowed down by video generator accesses.
 *   %   Single processor; MC == MASSCOMP
 *   NM  A version 7 C compiler written at New Mexico Tech.
 *   @   vanilla Lattice compiler used with MicroPro standard library
 *   S   Shorts used instead of ints
 *   T	 with Chris Torek's patches (whatever they are).
 *   ~   For WICAT Systems: MB=MultiBus, PB=Proprietary Bus
 *   LM  Large Memory Model. (Otherwise, all 80x8x results are small model)
 *   MM  Medium Memory Model. (Otherwise, all 80x8x results are small model)
 *   C1  Univation PC TURBO Co-processor; 9.54Mhz 8086, 640K RAM
 *   C2  Seattle Telecom STD-286 board
 *   C3  Definicon DSI-32 coprocessor
 *   C?  Unknown co-processor board?
 *   CT1 Convergent Technologies MegaFrame, 1 processor.
 *   MN  Using Mike Newtons 'optimizer' (see net.sources).
 *   G1  This Gould machine has 2 processors and was able to run 2 dhrystone
 *       Benchmarks in parallel with no slowdown.
 *   FH  FHC == Frank Hogg Labs (Hazelwood Uniquad 2 in an FHL box).
 *   FX  The Alliant FX/8 is a system consisting of 1-8 CEs (computation
 *	 engines) and 1-12 IPs (interactive processors). Note N8 applies.
 *   RT  This is one of the RT's that CMU has been using for awhile.  I'm
 *	 not sure that this is identical to the machine that IBM is selling
 *	 to the public.
 *   i1  Normally, the 386/20 starter kit has a 16k direct mapped cache
 *	 which inserts 2 or 3 wait states on a write thru.  These results
 *	 were obtained by disabling the write-thru, or essentially turning
 *	 the cache into 0 wait state memory.
 *   Nnn This machine has multiple processors, allowing "nn" copies of the
 *	 benchmark to run in the same time as 1 copy.
 *   &nn This machine has "nn" processors, and the benchmark results were
 *	 obtained by having all "nn" processors working on 1 copy of dhrystone.
 *	 (Note, this is different than Nnn. Salesmen like this measure).
 *   ?   I don't trust results marked with '?'.  These were sent to me with
 *       either incomplete info, or with times that just don't make sense.
 *	 ?? means I think the performance is too poor, ?! means too good.
 *       If anybody can confirm these figures, please respond.
 *
 *  ABBREVIATIONS
 *	CCC	Concurrent Computer Corp. (was Perkin-Elmer)
 *	MC	Masscomp
 *
 *--------------------------------RESULTS END----------------------------------
 *
 *	The following program contains statements of a high-level programming
 *	language (C) in a distribution considered representative:
 *
 *	assignments			53%
 *	control statements		32%
 *	procedure, function calls	15%
 *
 *	100 statements are dynamically executed.  The program is balanced with
 *	respect to the three aspects:
 *		- statement type
 *		- operand type (for simple data types)
 *		- operand access
 *			operand global, local, parameter, or constant.
 *
 *	The combination of these three aspects is balanced only approximately.
 *
 *	The program does not compute anything meaningfull, but it is
 *	syntactically and semantically correct.
 *
 */

/* Accuracy of timings and human fatigue controlled by next two lines */
/*#define LOOPS	5000		/* Use this for slow or 16 bit machines */
#define LOOPS	500000		/* Use this for slow or 16 bit machines */
/*#define LOOPS	500000		/* Use this for faster machines */

/* Compiler dependent options */
#undef	NOENUM			/* Define if compiler has no enum's */
#undef	NOSTRUCTASSIGN		/* Define if compiler can't assign structures */

/* define only one of the next two defines */
//#define TIMES			/* Use times(2) time function */
/*#define TIME			/* Use time(2) time function */

#include "kasirga.h"

/* for compatibility with goofed up version */
/*#define GOOF			/* Define if you want the goofed up version */

#ifdef GOOF
char	Version[] = "1.0";
#else
char	Version[] = "1.1";
#endif

#ifdef	NOSTRUCTASSIGN
#define	structassign(d, s)	memcpy(&(d), &(s), sizeof(d))
#else
#define	structassign(d, s)	d = s
#endif

#ifdef	NOENUM
#define	Ident1	1
#define	Ident2	2
#define	Ident3	3
#define	Ident4	4
#define	Ident5	5
typedef int	Enumeration;
#else
typedef enum	{Ident1, Ident2, Ident3, Ident4, Ident5} Enumeration;
#endif

#define arith64_u64 unsigned long long int
#define arith64_s64 signed long long int
#define arith64_u32 unsigned int
#define arith64_s32 int

typedef union
{
    arith64_u64 u64;
    arith64_s64 s64;
    struct
    {
#if __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
        arith64_u32 hi; arith64_u32 lo;
#else
        arith64_u32 lo; arith64_u32 hi;
#endif
    } u32;
    struct
    {
#if __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
        arith64_s32 hi; arith64_s32 lo;
#else
        arith64_s32 lo; arith64_s32 hi;
#endif
    } s32;
} arith64_word;

// extract hi and lo 32-bit words from 64-bit value
#define arith64_hi(n) (arith64_word){.u64=n}.u32.hi
#define arith64_lo(n) (arith64_word){.u64=n}.u32.lo

// Negate a if b is negative, via invert and increment.
#define arith64_neg(a, b) (((a) ^ ((((arith64_s64)(b)) >= 0) - 1)) + (((arith64_s64)(b)) < 0))
#define arith64_abs(a) arith64_neg(a, a)

// Return the absolute value of a.
// Note LLINT_MIN cannot be negated.
arith64_s64 __absvdi2(arith64_s64 a)
{
    return arith64_abs(a);
}

// Return the result of shifting a left by b bits.
arith64_s64 __ashldi3(arith64_s64 a, int b)
{
    arith64_word w = {.s64 = a};

    b &= 63;

    if (b >= 32)
    {
        w.u32.hi = w.u32.lo << (b - 32);
        w.u32.lo = 0;
    } else if (b)
    {
        w.u32.hi = (w.u32.lo >> (32 - b)) | (w.u32.hi << b);
        w.u32.lo <<= b;
    }
    return w.s64;
}

// Return the result of arithmetically shifting a right by b bits.
arith64_s64 __ashrdi3(arith64_s64 a, int b)
{
    arith64_word w = {.s64 = a};

    b &= 63;

    if (b >= 32)
    {
        w.s32.lo = w.s32.hi >> (b - 32);
        w.s32.hi >>= 31; // 0xFFFFFFFF or 0
    } else if (b)
    {
        w.u32.lo = (w.u32.hi << (32 - b)) | (w.u32.lo >> b);
        w.s32.hi >>= b;
    }
    return w.s64;
}

// These functions return the number of leading 0-bits in a, starting at the
// most significant bit position. If a is zero, the result is undefined.
int __clzsi2(arith64_u32 a)
{
    int b, n = 0;
    b = !(a & 0xffff0000) << 4; n += b; a <<= b;
    b = !(a & 0xff000000) << 3; n += b; a <<= b;
    b = !(a & 0xf0000000) << 2; n += b; a <<= b;
    b = !(a & 0xc0000000) << 1; n += b; a <<= b;
    return n + !(a & 0x80000000);
}

int __clzdi2(arith64_u64 a)
{
    int b, n = 0;
    b = !(a & 0xffffffff00000000ULL) << 5; n += b; a <<= b;
    b = !(a & 0xffff000000000000ULL) << 4; n += b; a <<= b;
    b = !(a & 0xff00000000000000ULL) << 3; n += b; a <<= b;
    b = !(a & 0xf000000000000000ULL) << 2; n += b; a <<= b;
    b = !(a & 0xc000000000000000ULL) << 1; n += b; a <<= b;
    return n + !(a & 0x8000000000000000ULL);
}

// These functions return the number of trailing 0-bits in a, starting at the
// least significant bit position. If a is zero, the result is undefined.
int __ctzsi2(arith64_u32 a)
{
    int b, n = 0;
    b = !(a & 0x0000ffff) << 4; n += b; a >>= b;
    b = !(a & 0x000000ff) << 3; n += b; a >>= b;
    b = !(a & 0x0000000f) << 2; n += b; a >>= b;
    b = !(a & 0x00000003) << 1; n += b; a >>= b;
    return n + !(a & 0x00000001);
}

int __ctzdi2(arith64_u64 a)
{
    int b, n = 0;
    b = !(a & 0x00000000ffffffffULL) << 5; n += b; a >>= b;
    b = !(a & 0x000000000000ffffULL) << 4; n += b; a >>= b;
    b = !(a & 0x00000000000000ffULL) << 3; n += b; a >>= b;
    b = !(a & 0x000000000000000fULL) << 2; n += b; a >>= b;
    b = !(a & 0x0000000000000003ULL) << 1; n += b; a >>= b;
    return n + !(a & 0x0000000000000001ULL);
}

// Calculate both the quotient and remainder of the unsigned division of a and
// b. The return value is the quotient, and the remainder is placed in variable
// pointed to by c (if it's not NULL).
arith64_u64 __divmoddi4(arith64_u64 a, arith64_u64 b, arith64_u64 *c)
{
    if (b > a)                                  // divisor > numerator?
    {
        if (c) *c = a;                          // remainder = numerator
        return 0;                               // quotient = 0
    }
    if (!arith64_hi(b))                         // divisor is 32-bit
    {
        if (b == 0)                             // divide by 0
        {
            volatile char x = 0; x = 1 / x;     // force an exception
        }
        if (b == 1)                             // divide by 1
        {
            if (c) *c = 0;                      // remainder = 0
            return a;                           // quotient = numerator
        }
        if (!arith64_hi(a))                     // numerator is also 32-bit
        {
            if (c)                              // use generic 32-bit operators
                *c = arith64_lo(a) % arith64_lo(b);
            return arith64_lo(a) / arith64_lo(b);
        }
    }

    // let's do long division
    char bits = __clzdi2(b) - __clzdi2(a) + 1;  // number of bits to iterate (a and b are non-zero)
    arith64_u64 rem = a >> bits;                   // init remainder
    a <<= 64 - bits;                            // shift numerator to the high bit
    arith64_u64 wrap = 0;                          // start with wrap = 0
    while (bits-- > 0)                          // for each bit
    {
        rem = (rem << 1) | (a >> 63);           // shift numerator MSB to remainder LSB
        a = (a << 1) | (wrap & 1);              // shift out the numerator, shift in wrap
        wrap = ((arith64_s64)(b - rem - 1) >> 63);  // wrap = (b > rem) ? 0 : 0xffffffffffffffff (via sign extension)
        rem -= b & wrap;                        // if (wrap) rem -= b
    }
    if (c) *c = rem;                            // maybe set remainder
    return (a << 1) | (wrap & 1);               // return the quotient
}

// Return the quotient of the signed division of a and b.
arith64_s64 __divdi3(arith64_s64 a, arith64_s64 b)
{
    arith64_u64 q = __divmoddi4(arith64_abs(a), arith64_abs(b), (void *)0);
    return arith64_neg(q, a^b); // negate q if a and b signs are different
}

// Return the index of the least significant 1-bit in a, or the value zero if a
// is zero. The least significant bit is index one.
int __ffsdi2(arith64_u64 a)
{
    return a ? __ctzdi2(a) + 1 : 0;
}

// Return the result of logically shifting a right by b bits.
arith64_u64 __lshrdi3(arith64_u64 a, int b)
{
    arith64_word w = {.u64 = a};

    b &= 63;

    if (b >= 32)
    {
        w.u32.lo = w.u32.hi >> (b - 32);
        w.u32.hi = 0;
    } else if (b)
    {
        w.u32.lo = (w.u32.hi << (32 - b)) | (w.u32.lo >> b);
        w.u32.hi >>= b;
    }
    return w.u64;
}

// Return the remainder of the signed division of a and b.
arith64_s64 __moddi3(arith64_s64 a, arith64_s64 b)
{
    arith64_u64 r;
    __divmoddi4(arith64_abs(a), arith64_abs(b), &r);
    return arith64_neg(r, a); // negate remainder if numerator is negative
}

// Return the number of bits set in a.
int __popcountsi2(arith64_u32 a)
{
    // collect sums into two low bytes
    a = a - ((a >> 1) & 0x55555555);
    a = ((a >> 2) & 0x33333333) + (a & 0x33333333);
    a = (a + (a >> 4)) & 0x0F0F0F0F;
    a = (a + (a >> 16));
    // add the bytes, return bottom 6 bits
    return (a + (a >> 8)) & 63;
}

// Return the number of bits set in a.
int __popcountdi2(arith64_u64 a)
{
    // collect sums into two low bytes
    a = a - ((a >> 1) & 0x5555555555555555ULL);
    a = ((a >> 2) & 0x3333333333333333ULL) + (a & 0x3333333333333333ULL);
    a = (a + (a >> 4)) & 0x0F0F0F0F0F0F0F0FULL;
    a = (a + (a >> 32));
    a = (a + (a >> 16));
    // add the bytes, return bottom 7 bits
    return (a + (a >> 8)) & 127;
}

int exit() {
	return 0;
}

// Return the quotient of the unsigned division of a and b.
arith64_u64 __udivdi3(arith64_u64 a, arith64_u64 b)
{
    return __divmoddi4(a, b, (void *)0);
}

// Return the remainder of the unsigned division of a and b.
arith64_u64 __umoddi3(arith64_u64 a, arith64_u64 b)
{
    arith64_u64 r;
    __divmoddi4(a, b, &r);
    return r;
}

typedef int	OneToThirty;
typedef int	OneToFifty;
typedef char	CapitalLetter;
typedef char	String30[31];
typedef int	Array1Dim[51];
typedef int	Array2Dim[51][51];

struct	Record
{
	struct Record		*PtrComp;
	Enumeration		Discr;
	Enumeration		EnumComp;
	OneToFifty		IntComp;
	String30		StringComp;
};

typedef struct Record 	RecordType;
typedef RecordType *	RecordPtr;
typedef int		boolean;

#define	NULL		0
#define	TRUE		1
#define	FALSE		0

#ifndef REG
#define	REG
#endif

extern Enumeration	Func1();
extern boolean		Func2();

#ifdef TIMES
#include <sys/types.h>
#include <sys/times.h>
#endif

char* strcpy(char* dest, const char* src)
{
  char* d = dest;
  while ((*d++ = *src++))
    ;
  return dest;
}

int strcmp(const char* s1, const char* s2)
{
  unsigned char c1, c2;

  do {
    c1 = *s1++;
    c2 = *s2++;
  } while (c1 != 0 && c1 == c2);

  return c1 - c2;
}

#define CORETIMETYPE uint64_t
#define CORE_TICKS uint64_t

CORETIMETYPE
barebones_clock()
{
    return *(uint64_t*) 0x30000000;
}
/* Define : TIMER_RES_DIVIDER
        Divider to trade off timer resolution and total time that can be
   measured.

        Use lower values to increase resolution, but make sure that overflow
   does not occur. If there are issues with the return value overflowing,
   increase this value.
        */
#define GETMYTIME(_t)              (*_t = barebones_clock())
#define MYTIMEDIFF(fin, ini)       ((fin) - (ini))
#define TIMER_RES_DIVIDER          1
#define SAMPLE_TIME_IMPLEMENTATION 1
#define EE_TICKS_PER_SEC           (CPU_HZ / TIMER_RES_DIVIDER)

/** Define Host specific (POSIX), or target specific global time variables. */
static CORETIMETYPE start_time_val, stop_time_val;

/* Function : start_time
        This function will be called right before starting the timed portion of
   the benchmark.

        Implementation may be capturing a system timer (as implemented in the
   example code) or zeroing some system parameters - e.g. setting the cpu clocks
   cycles to 0.
*/
void
start_time(void)
{
    GETMYTIME(&start_time_val);
}
/* Function : stop_time
        This function will be called right after ending the timed portion of the
   benchmark.

        Implementation may be capturing a system timer (as implemented in the
   example code) or other system parameters - e.g. reading the current value of
   cpu cycles counter.
*/
void
stop_time(void)
{
    GETMYTIME(&stop_time_val);
}
/* Function : get_time
        Return an abstract "ticks" number that signifies time on the system.

        Actual value returned may be cpu cycles, milliseconds or any other
   value, as long as it can be converted to seconds by <time_in_secs>. This
   methodology is taken to accommodate any hardware or simulated platform. The
   sample implementation returns millisecs by default, and the resolution is
   controlled by <TIMER_RES_DIVIDER>
*/
CORE_TICKS
get_time(void)
{
    CORE_TICKS elapsed
        = (CORE_TICKS)(MYTIMEDIFF(stop_time_val, start_time_val));
    return elapsed;
}

main()
{
    uart_set_ctrl(CPU_HZ / BAUD_RATE, 1, 1);
	ee_printf("KASIRGA\n");
	Proc0();
	exit(0);
}

/*
 * Package 1
 */
int		IntGlob;
boolean		BoolGlob;
char		Char1Glob;
char		Char2Glob;
Array1Dim	Array1Glob;
Array2Dim	Array2Glob;
RecordPtr	PtrGlb;
RecordPtr	PtrGlbNext;

static char mem[2024];

char* malloc(uint32_t size) {
	static char* malloc_ptr = mem;
	char* src = mem;
	malloc_ptr += size;
	return src;
}

Proc0()
{
	OneToFifty		IntLoc1;
	REG OneToFifty		IntLoc2;
	OneToFifty		IntLoc3;
	REG char		CharLoc;
	REG char		CharIndex;
	Enumeration	 	EnumLoc;
	String30		String1Loc;
	String30		String2Loc;

	register unsigned int	i;
#ifdef TIME
	long			time();
	long			starttime;
	long			benchtime;
	long			nulltime;

	starttime = time( (long *) 0);
	for (i = 0; i < LOOPS; ++i);
	nulltime = time( (long *) 0) - starttime; /* Computes o'head of loop */
#endif
#ifdef TIMES
	time_t			starttime;
	time_t			benchtime;
	time_t			nulltime;
	struct tms		tms;

	times(&tms); starttime = tms.tms_utime;
	for (i = 0; i < LOOPS; ++i);
	times(&tms);
	nulltime = tms.tms_utime - starttime; /* Computes overhead of looping */
#endif
    start_time();
	for (i = 0; i < LOOPS; ++i);
    stop_time();
    uint64_t nulltime = get_time();

	PtrGlbNext = (RecordPtr) malloc(sizeof(RecordType));
	PtrGlb = (RecordPtr) malloc(sizeof(RecordType));
	PtrGlb->PtrComp = PtrGlbNext;
	PtrGlb->Discr = Ident1;
	PtrGlb->EnumComp = Ident3;
	PtrGlb->IntComp = 40;
	strcpy(PtrGlb->StringComp, "DHRYSTONE PROGRAM, SOME STRING");
#ifndef	GOOF
	strcpy(String1Loc, "DHRYSTONE PROGRAM, 1'ST STRING");	/*GOOF*/
#endif
	Array2Glob[8][7] = 10;	/* Was missing in published program */

/*****************
-- Start Timer --
*****************/
#ifdef TIME
	starttime = time( (long *) 0);
#endif
#ifdef TIMES
	times(&tms); starttime = tms.tms_utime;
#endif
    start_time();
	for (i = 0; i < LOOPS; ++i)
	{
		Proc5();
		Proc4();
		IntLoc1 = 2;
		IntLoc2 = 3;
		strcpy(String2Loc, "DHRYSTONE PROGRAM, 2'ND STRING");
		EnumLoc = Ident2;
		BoolGlob = ! Func2(String1Loc, String2Loc);
		while (IntLoc1 < IntLoc2)
		{
			IntLoc3 = 5 * IntLoc1 - IntLoc2;
			Proc7(IntLoc1, IntLoc2, &IntLoc3);
			++IntLoc1;
		}
		Proc8(Array1Glob, Array2Glob, IntLoc1, IntLoc3);
		Proc1(PtrGlb);
		for (CharIndex = 'A'; CharIndex <= Char2Glob; ++CharIndex)
			if (EnumLoc == Func1(CharIndex, 'C'))
				Proc6(Ident1, &EnumLoc);
		IntLoc3 = IntLoc2 * IntLoc1;
		IntLoc2 = IntLoc3 / IntLoc1;
		IntLoc2 = 7 * (IntLoc3 - IntLoc2) - IntLoc1;
		Proc2(&IntLoc1);
	}

/*****************
-- Stop Timer --
*****************/

#ifdef TIME
	benchtime = time( (long *) 0) - starttime - nulltime;
	printf("Dhrystone(%s) time for %ld passes = %ld\n",
		Version,
		(long) LOOPS, benchtime);
	printf("This machine benchmarks at %ld dhrystones/second\n",
		((long) LOOPS) / benchtime);
#endif
#ifdef TIMES
	times(&tms);
	benchtime = tms.tms_utime - starttime - nulltime;
	printf("Dhrystone(%s) time for %ld passes = %ld\n",
		Version,
		(long) LOOPS, benchtime/HZ);
	printf("This machine benchmarks at %ld dhrystones/second\n",
		((long) LOOPS) * HZ / benchtime);
#endif
    stop_time();
    uint64_t benchtime = get_time() - nulltime;
	uint64_t seconds = benchtime / CPU_HZ;
	ee_printf("Dhrystone(%s) time for %ld passes = %ld\n",
		Version,
		(long) LOOPS, seconds);
	ee_printf("This machine benchmarks at %ld dhrystones/second\n", LOOPS / seconds);
}

Proc1(PtrParIn)
REG RecordPtr	PtrParIn;
{
#define	NextRecord	(*(PtrParIn->PtrComp))

	structassign(NextRecord, *PtrGlb);
	PtrParIn->IntComp = 5;
	NextRecord.IntComp = PtrParIn->IntComp;
	NextRecord.PtrComp = PtrParIn->PtrComp;
	Proc3(NextRecord.PtrComp);
	if (NextRecord.Discr == Ident1)
	{
		NextRecord.IntComp = 6;
		Proc6(PtrParIn->EnumComp, &NextRecord.EnumComp);
		NextRecord.PtrComp = PtrGlb->PtrComp;
		Proc7(NextRecord.IntComp, 10, &NextRecord.IntComp);
	}
	else
		structassign(*PtrParIn, NextRecord);

#undef	NextRecord
}

Proc2(IntParIO)
OneToFifty	*IntParIO;
{
	REG OneToFifty		IntLoc;
	REG Enumeration		EnumLoc;

	IntLoc = *IntParIO + 10;
	for(;;)
	{
		if (Char1Glob == 'A')
		{
			--IntLoc;
			*IntParIO = IntLoc - IntGlob;
			EnumLoc = Ident1;
		}
		if (EnumLoc == Ident1)
			break;
	}
}

Proc3(PtrParOut)
RecordPtr	*PtrParOut;
{
	if (PtrGlb != NULL)
		*PtrParOut = PtrGlb->PtrComp;
	else
		IntGlob = 100;
	Proc7(10, IntGlob, &PtrGlb->IntComp);
}

Proc4()
{
	REG boolean	BoolLoc;

	BoolLoc = Char1Glob == 'A';
	BoolLoc |= BoolGlob;
	Char2Glob = 'B';
}

Proc5()
{
	Char1Glob = 'A';
	BoolGlob = FALSE;
}

extern boolean Func3();

Proc6(EnumParIn, EnumParOut)
REG Enumeration	EnumParIn;
REG Enumeration	*EnumParOut;
{
	*EnumParOut = EnumParIn;
	if (! Func3(EnumParIn) )
		*EnumParOut = Ident4;
	switch (EnumParIn)
	{
	case Ident1:	*EnumParOut = Ident1; break;
	case Ident2:	if (IntGlob > 100) *EnumParOut = Ident1;
			else *EnumParOut = Ident4;
			break;
	case Ident3:	*EnumParOut = Ident2; break;
	case Ident4:	break;
	case Ident5:	*EnumParOut = Ident3;
	}
}

Proc7(IntParI1, IntParI2, IntParOut)
OneToFifty	IntParI1;
OneToFifty	IntParI2;
OneToFifty	*IntParOut;
{
	REG OneToFifty	IntLoc;

	IntLoc = IntParI1 + 2;
	*IntParOut = IntParI2 + IntLoc;
}

Proc8(Array1Par, Array2Par, IntParI1, IntParI2)
Array1Dim	Array1Par;
Array2Dim	Array2Par;
OneToFifty	IntParI1;
OneToFifty	IntParI2;
{
	REG OneToFifty	IntLoc;
	REG OneToFifty	IntIndex;

	IntLoc = IntParI1 + 5;
	Array1Par[IntLoc] = IntParI2;
	Array1Par[IntLoc+1] = Array1Par[IntLoc];
	Array1Par[IntLoc+30] = IntLoc;
	for (IntIndex = IntLoc; IntIndex <= (IntLoc+1); ++IntIndex)
		Array2Par[IntLoc][IntIndex] = IntLoc;
	++Array2Par[IntLoc][IntLoc-1];
	Array2Par[IntLoc+20][IntLoc] = Array1Par[IntLoc];
	IntGlob = 5;
}

Enumeration Func1(CharPar1, CharPar2)
CapitalLetter	CharPar1;
CapitalLetter	CharPar2;
{
	REG CapitalLetter	CharLoc1;
	REG CapitalLetter	CharLoc2;

	CharLoc1 = CharPar1;
	CharLoc2 = CharLoc1;
	if (CharLoc2 != CharPar2)
		return (Ident1);
	else
		return (Ident2);
}

boolean Func2(StrParI1, StrParI2)
String30	StrParI1;
String30	StrParI2;
{
	REG OneToThirty		IntLoc;
	REG CapitalLetter	CharLoc;

	IntLoc = 1;
	while (IntLoc <= 1)
		if (Func1(StrParI1[IntLoc], StrParI2[IntLoc+1]) == Ident1)
		{
			CharLoc = 'A';
			++IntLoc;
		}
	if (CharLoc >= 'W' && CharLoc <= 'Z')
		IntLoc = 7;
	if (CharLoc == 'X')
		return(TRUE);
	else
	{
		if (strcmp(StrParI1, StrParI2) > 0)
		{
			IntLoc += 7;
			return (TRUE);
		}
		else
			return (FALSE);
	}
}

boolean Func3(EnumParIn)
REG Enumeration	EnumParIn;
{
	REG Enumeration	EnumLoc;

	EnumLoc = EnumParIn;
	if (EnumLoc == Ident3) return (TRUE);
	return (FALSE);
}

#ifdef	NOSTRUCTASSIGN
memcpy(d, s, l)
register char	*d;
register char	*s;
register int	l;
{
	while (l--) *d++ = *s++;
}
#endif
/* ---------- */
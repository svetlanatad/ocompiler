MODULE PARSER;

IMPORT Out, scanner, Files, Strings;

TYPE
    symbol = RECORD
        Identifier: scanner.Identifier;
        Digit: INTEGER;
    END;    

VAR 
    sym: INTEGER;
    symtable: ARRAY 64 OF symbol;
    symtableLen: INTEGER;
    ch: CHAR;
    r: Files.Rider;
    idName: scanner.Identifier;
    f: Files.File;
    prgName: scanner.Identifier;
    errc: INTEGER;

PROCEDURE error(msg: ARRAY OF CHAR);
BEGIN
  Out.String(msg); Out.Ln;
  INC(errc);
  Out.String("current error count: "); Out.Int(errc, 0); Out.Ln;
END error;

PROCEDURE checkError(err: INTEGER);
BEGIN
  IF err > 0 THEN 
    Out.String("you have an error: halting. "); Out.Ln; HALT(0);
  END;
END checkError;

PROCEDURE checkprgname(str: ARRAY OF CHAR): BOOLEAN;
(*corrupted: dont use, i may think later*)
VAR 
  b: BOOLEAN;
  i: INTEGER;
BEGIN 
  b := TRUE;
  IF (LEN(str) # LEN(prgName)) THEN b := FALSE; RETURN b END;
  Out.String("they may be the same now as the lengths of the strings are the same"); 
  i := 0;
  REPEAT
    IF str[i] # prgName[i] THEN Out.Char(str[i]); Out.String("is different from "); Out.Char(prgName[i]); Out.Ln; b := FALSE; END;
    Out.Char(str[i]); Out.Ln; Out.Char(prgName[i]); Out.Ln; 
    INC(i);
  UNTIL (prgName[i] = 0X) & (str[i] = 0X);
RETURN b;
END checkprgname;

PROCEDURE addToSymTable(idName: scanner.Identifier);
VAR 
  i: INTEGER;
  b: BOOLEAN;
BEGIN
    Out.String("Adding to symbol table: "); Out.String(idName); Out.Ln;
    i := 0;
    REPEAT
      IF symtable[i].Identifier = idName THEN 
        error("variable already exists in sym table"); Out.Ln; RETURN; END;
      Out.String("trying to check if the var name = prg name");
       b := Strings.Match(symtable[i].Identifier, prgName);
        IF b THEN 
        error("variable cannot have the same name as the program"); Out.Ln; RETURN; 
        END;
      
      INC(i);
    UNTIL (symtable[i].Identifier = 0X);
    symtable[symtableLen].Identifier := idName;
    INC(symtableLen);
    Out.String("Variable "); Out.String(idName); Out.String(" added to symbol table."); Out.Ln;
    (*symtable[symtableLen].Digit := sym;*)
    Out.String("symbol after adding the previous ident to sym tabel"); Out.Int(sym, 0); Out.Ln;
END addToSymTable;



PROCEDURE type;
BEGIN
    Out.String("Checking type declaration, current sym: "); Out.Int(sym, 0); Out.Ln;
    IF sym = scanner.stringdecl THEN 
        Out.String("Got a string declaration"); Out.Ln; 
    ELSIF sym = scanner.integerdecl THEN 
        Out.String("Got an integer declaration"); Out.Ln;
    ELSE 
        (*Out.String("Operand can be either string or integer; this is neither."); Out.Ln; *) error("Operand can be either string or integer; this is neither. "); 
    END;
END type;




PROCEDURE operand;
BEGIN

IF (sym = scanner.numb) THEN RETURN; ELSIF (sym = scanner.ident) THEN RETURN; END;

scanner.GetSym; sym := scanner.sym;
    Out.String("Checking operand, current sym: "); Out.Int(sym, 0); Out.Ln;
    IF sym = scanner.numb THEN
        Out.String("Got a number type"); Out.Ln;
    ELSIF sym = scanner.ident THEN
        Out.String("Got an identifier type"); Out.Ln;
    ELSE
        Out.String("Operand can be either number or identifier; this is neither."); Out.Ln;
    END;
END operand;






PROCEDURE varSeq;

BEGIN
    Out.String("Entering varSeq, current sym: "); Out.Int(sym, 0); Out.Ln;

    IF sym # scanner.ident THEN 
        Out.String("Expected identifier. But i dont know maybe i checked already before. "); Out.Ln;
    ELSE 
        scanner.GetSym; sym := scanner.sym; 
        
        idName := scanner.id;
        Out.String("Identifier found in varSeq: "); Out.String(idName); Out.Ln;
        Out.String("adding it to sym table" ); addToSymTable(idName); Out.Ln;

	(*IF (idName = prgName) THEN Out.String("Error: You cannot put program name for a variable."); Out.Ln; END;*)
        IF sym = scanner.comm THEN 
            Out.String("Comma found, calling varSeq recursively."); Out.Ln;
            scanner.GetSym; sym := scanner.sym; 
           Out.String("calling getsym for recursion so the current sym is: "); Out.Int(sym, 0); Out.Ln;
            varSeq;
        ELSE 
            IF sym = scanner.de THEN
                Out.String("Colon found, expecting type declaration."); Out.Ln;
                scanner.GetSym; sym := scanner.sym;
                type; 
                scanner.GetSym; sym := scanner.sym;
                Out.String("After type in varSeq, sym: "); Out.Int(sym, 0); Out.Ln;

                IF sym # scanner.ks THEN 
                    Out.String("Expected ';' after type declaration."); Out.Ln;
                ELSE
                    Out.String("Semicolon found after type declaration."); Out.Ln;
	    Out.String("Calling varseq again. Maybe there are more idents. ");
	    scanner.GetSym; sym := scanner.sym; 
	    Out.String("calling getsym for recursion so the current sym is: "); Out.Int(sym, 0); Out.Ln;
	    varSeq;
	END;
    ELSE
	Out.String("Expected ':' after identifier."); Out.Ln;
    END;
END;
END; 
END varSeq; 






PROCEDURE varDefs;
BEGIN
Out.String("Entering varDefs, expecting 'var'."); Out.Ln;
scanner.GetSym; sym := scanner.sym;
Out.String("After GetSym in varDefs, sym: "); Out.Int(sym, 0); Out.Ln;

IF sym # scanner.varsym THEN 
Out.String("Expected 'var'."); Out.Ln;
ELSE 
Out.String("'var' keyword found, calling varSeq."); Out.Ln;
scanner.GetSym; sym := scanner.sym;
Out.String("After GetSym after finding var:  "); Out.Int(sym, 0); Out.Ln;
IF sym # scanner.ident THEN Out.String("after var has to be an identifier. still in vardef "); Out.Ln; ELSE
Out.String("entering varseq from vardef finaly "); Out.Ln;
varSeq;
END;
END;
END varDefs;








PROCEDURE prgHeader;
BEGIN
scanner.GetSym; sym := scanner.sym;
Out.String("Entering prgHeader, current sym: "); Out.Int(sym, 0); Out.Ln;

IF sym # scanner.prg THEN 
Out.String("Expected 'program' keyword."); Out.Ln;
ELSE
Out.String("Good job. You wrote the keyword program. Let me remember your program name");

scanner.GetSym; sym := scanner.sym;
IF sym # scanner.ident THEN
    Out.String("Expected identifier after 'program'."); Out.Ln;
ELSE
Out.String("Here I go. Your program name is..."); Out.Ln;
    scanner.GetSym; sym := scanner.sym; idName := scanner.id;
    Out.String("Program identifier found: "); Out.String(idName); Out.Ln;
Out.String("Remembering now...");
prgName := scanner.id;
    IF sym # scanner.ks THEN Out.String("Expected ';' after program name."); Out.Ln;
    ELSE Out.String("Semicolon after program name found."); Out.Ln;
    END;
END;
END;
END prgHeader;

PROCEDURE mathOp(idName: scanner.Identifier);
BEGIN
Out.String("Entering mathOp with idName: "); Out.String(idName); Out.Ln;
IF (sym = scanner.pl) OR (sym = scanner.mi) THEN Out.String("EITHER PL OR MINUS SO I WILL READ THE NEXT SYMBEL AND EXIT"); Out.Ln; scanner.GetSym; sym := scanner.sym; RETURN; END;

scanner.GetSym; sym := scanner.sym;
Out.String("After Entering mathOp with idName the curr sym is: "); Out.Int(sym,0); Out.Ln;
Out.String("sym just before checking if its pl or minus"); Out.Int(sym,0); Out.Ln;
IF (sym = scanner.pl) OR (sym = scanner.mi) THEN
Out.String("Operator found in mathOp."); Out.Ln;
scanner.GetSym; sym := scanner.sym;
ELSE
Out.String("Expected operator (+ or -) after first operand."); Out.Ln;
END;
END mathOp;


PROCEDURE GetSymTableEntry*(index: INTEGER; VAR idName: scanner.Identifier; VAR value: INTEGER);
BEGIN
IF (index < 0) OR  (index >= symtableLen) THEN 
	Out.String("Out of bounds error. "); Out.Ln;
RETURN;	
END;

idName := symtable[index].Identifier;
value := symtable[index].Digit;

END GetSymTableEntry;


PROCEDURE simpleOrComplexAssignment;
BEGIN
    Out.String("Entering simpleOrComplexAssignment"); Out.Ln;

    IF sym = scanner.ident THEN
        idName := scanner.id;
        Out.String("Identifier found for assignment: "); Out.String(idName); Out.Ln;
        scanner.GetSym; sym := scanner.sym;

        IF sym = scanner.as THEN
            Out.String("Assignment ':=' found."); Out.Ln;

            operand;

            scanner.GetSym; sym := scanner.sym;
            IF (sym = scanner.ks) THEN
                (* Simple assignment *)
                Out.String("Simple Assignment: Adding to sym table the following ident: "); Out.String(idName); Out.Ln;
                addToSymTable(idName);
            ELSE
		    mathOp(idName);
                    Out.String("Math operator found."); Out.Ln;
                    operand;
		    Out.String("operand found?"); Out.Ln; scanner.GetSym; sym := scanner.sym;
                    IF sym = scanner.ks THEN
                        (*Complex assignment*)
                        Out.String("ComplexAssignment: Adding to sym table the following ident: "); Out.String(idName); Out.Ln;
                        addToSymTable(idName);
                     ELSE
                        Out.String("Expected ';' after operand."); Out.Ln;
                    END;
               END;
	 ELSE
                    Out.String("Expected ';' or math operator after operand."); Out.Ln;
                END;
   ELSE     
            Out.String("Expected ':=' after identifier."); Out.Ln;
        END;
END simpleOrComplexAssignment;

PROCEDURE statementSeq;
BEGIN
    Out.String("Entering statementSeq."); Out.Ln;

    WHILE sym # scanner.endsym DO
        IF sym = scanner.ident THEN
            simpleOrComplexAssignment;
            IF sym = scanner.ks THEN
                Out.String("Semicolon found after statement."); Out.Ln;
               scanner.GetSym; sym := scanner.sym; 
               symtable[symtableLen].Digit := sym;
            ELSE
                Out.String("Expected ';' after statement."); Out.Ln;
                RETURN;
            END;
        ELSE
            Out.String("Invalid statement. Expecting identifier."); Out.Ln;
            RETURN;
        END;
    END;

    Out.String("End symbol found, exiting statementSeq."); Out.Ln;
END statementSeq;

PROCEDURE prg;
BEGIN
    Out.String("Starting program parsing."); Out.Ln;
    prgHeader;
    varDefs;

    Out.String("After varDefs, current sym: "); Out.Int(sym, 0); Out.Ln;
    IF sym # scanner.beginsym THEN
        Out.String("Expected 'begin'."); Out.Ln;
    ELSE
        Out.String("'begin' found, entering statementSeq."); Out.Ln;
        scanner.GetSym; sym := scanner.sym;
        statementSeq;
        IF sym # scanner.endsym THEN
            Out.String("Expected 'end'."); Out.Ln;
        ELSE
            Out.String("'end' found, parsing completed."); Out.Ln;
        END;
    END;
END prg;


PROCEDURE printsyms;
VAR 
  i: INTEGER;
BEGIN 
  i := 0;
  REPEAT
   Out.String("identifier: "); Out.String(symtable[i].Identifier); Out.Ln;
   Out.String("digit: "); Out.Int(symtable[i].Digit, 0); Out.Ln;
   INC(i);
  UNTIL i = symtableLen;
END printsyms;

PROCEDURE ParseProgram;
BEGIN
    symtableLen := 0;
    scanner.saveFile;
    prg;
    Out.String("Parsing completed."); Out.Ln;
END ParseProgram;

BEGIN
    errc := 0;
    ParseProgram;
    Out.String("############################################################"); Out.Ln;
    printsyms;
    Out.String("err count: "); Out.Int(errc, 0); Out.Ln;
    Out.String("prg name: "); Out.String(prgName); Out.Ln;
END PARSER.

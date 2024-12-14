MODULE scanner;

IMPORT Files, Out;

CONST
    maxLexemLength* = 32;
    eof* = -1;
    err* = -2;
    pl* = 0;
    mi* = 1;
    as* = 2;
    de* = 3;
    ks* = 4;
    ke* = 5;
    comm* = 6;
    varsym* = 7;
    beginsym* = 8;
    endsym* = 9;
    ident* = 10;
    numb* = 11;
    integerdecl* = 12;
    stringdecl* = 13;
    prg* = 14;

TYPE
    Identifier* = ARRAY maxLexemLength OF CHAR;

VAR
    ch: CHAR;
    sym*: INTEGER;
    id*: Identifier;
    rider: Files.Rider;

PROCEDURE GetCh*;
VAR readSuccess: BOOLEAN;
BEGIN
    Files.Read(rider, ch); (* Reads the next character from the file *)
    readSuccess := rider.res = 0; (* Check if the read was successful *)
    IF ~readSuccess THEN ch := 0X; (* If the read failed, set ch to 0X (EOF) *)
    END;
END GetCh;

PROCEDURE SkipWhiteSpace*;
BEGIN
    WHILE (ch <= " ") & (ch # 0X) DO GetCh END;
END SkipWhiteSpace;

PROCEDURE IsLetter(ch: CHAR): BOOLEAN;
BEGIN
    RETURN (ch >= "A") & (ch <= "Z") OR (ch >= "a") & (ch <= "z");
END IsLetter;

PROCEDURE IsDigit(ch: CHAR): BOOLEAN;
BEGIN
    RETURN (ch >= "0") & (ch <= "9");
END IsDigit;


PROCEDURE GetNumber*;
VAR numVal: INTEGER;
BEGIN
    numVal := 0;
    WHILE IsDigit(ch) DO
        numVal := numVal * 10 + (ORD(ch) - ORD("0"));
        GetCh;
    END;
    sym := numb;
END GetNumber;

PROCEDURE GetIdent*;
VAR i: INTEGER;
BEGIN
    i := 0;
    WHILE IsLetter(ch) OR IsDigit(ch) DO
        IF i < maxLexemLength THEN
            id[i] := ch;
            INC(i);
            GetCh;
        END;
    END;
    id[i] := 0X; (* Null-terminate the identifier *)

    (* Check for reserved words *)
    IF id = "var" THEN sym := varsym;
    ELSIF id = "begin" THEN sym := beginsym;
    ELSIF id = "end" THEN sym := endsym;
    ELSIF id = "integer" THEN sym := integerdecl;
    ELSIF id = "string" THEN sym := stringdecl;
    ELSIF id = "program" THEN sym := prg;
    ELSE sym := ident;
    END;
END GetIdent;

PROCEDURE GetSym*;
BEGIN
    SkipWhiteSpace;
    IF IsLetter(ch) THEN
        GetIdent;
    ELSIF IsDigit(ch) THEN
        GetNumber;
    ELSE
        CASE ch OF
            | "+" : sym := pl; GetCh;
            | "-" : sym := mi; GetCh;
            | ":" : 
                GetCh;
                IF ch = "=" THEN sym := as; GetCh ELSE sym := de END;
            | ";" : sym := ks; GetCh;
            | "." : sym := ke; GetCh;
            | "," : sym := comm; GetCh;
            | 0X : sym := eof;
        ELSE
            sym := err; (* Unknown character *)
            GetCh;
        END;
    END;
END GetSym;

PROCEDURE PrintSym*;
BEGIN
    CASE sym OF
        | pl : Out.String("term: +");
        | mi : Out.String("term: -");
        | as : Out.String("term: :=");
        | de : Out.String("term: :");
        | ks : Out.String("term: ;");
        | ke : Out.String("term: .");
        | comm : Out.String("term: ,");
        | varsym : Out.String("term: var");
        | beginsym : Out.String("term: begin");
        | endsym : Out.String("term: end");
        | stringdecl : Out.String("term: stringdecl");
        | integerdecl : Out.String("term: integerdecl");
        | prg : Out.String("term: program");
        | ident : Out.String("ident: "); Out.String(id);
        | numb : Out.String("number: "); Out.Int(ORD(ch), 0);
        | eof : Out.String("end of file");
        | err : Out.String("error, invalid term");
    ELSE
        Out.String("unknown symbol");
    END;
    Out.Ln;
END PrintSym;

PROCEDURE Scan*;
BEGIN
    REPEAT
        GetSym;
        PrintSym;
	Out.String("current sym: "); Out.Int(sym, 0); Out.Ln;
    UNTIL sym = eof;
END Scan;

PROCEDURE Main*;
VAR f: Files.File;
BEGIN
    f := Files.Old("input0.txt");
    IF f # NIL THEN
        Files.Set(rider, f, 0);
        GetCh;
        Scan;
    ELSE
        Out.String("File not found!"); Out.Ln;
    END;
END Main;


PROCEDURE saveFile*;

VAR f: Files.File;
BEGIN
f := Files.Old("input0.txt");
IF f # NIL THEN 
	Files.Set(rider, f, 0);
	GetCh;
ELSE
	Out.String("File not found");
END;

END saveFile;

END scanner.

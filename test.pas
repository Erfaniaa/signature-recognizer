 program UnicodeTextFile;
  uses
   Windows, SysUtils;

  const      // surrogate bytes    
   Clef = #$5B + #$D834 + #$DD1E + #$5D;

  var
   F: Text;
   B: Byte;
  begin
   Assign(F, 'output.txt');
   Rewrite(f);
   for B in TEncoding.UTF8.GetPreamble do write(f, AnsiChar(B));
   writeln(f, UTF8String('['+Clef+']'));
   writeln(f, 'This is a UTF-16 String which will be written as AnsiString');
   Close(f);
  end.
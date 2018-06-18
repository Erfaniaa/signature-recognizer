unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ExtDlgs, FileCtrl, Unit2, Buttons;

type
  TForm3 = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Image1: TImage;
    Shape1: TShape;
    FileListBox1: TFileListBox;
    Timer1: TTimer;
    procedure FileListBox1Click(Sender: TObject);
    procedure GroupBox2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FileListBox1Change(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  PenColor = clBlue;
  PenSColor = clRed;
  PenFColor = clWebOrange;
  PenSize = 3;
  PenSize2 = PenSize + 3;
  D = 28;
  Cha: array [1..4] of string[1] = ('', '0', '#', '$');

var
  Form3: TForm3;
  B: array [1..4] of Boolean;
  I, J, M, K: Integer;
  F: TextFile;
  Pnt: array [1..10000] of TPoint;
  Pt: array [1..2, 1..2500] of TPoint;

implementation

{$R *.dfm}

function Dis (X1, Y1, X2, Y2: Real): Real;
begin
  Dis := Sqrt (Sqr (X2 - X1) + Sqr (Y2 - Y1));
end;

procedure TForm3.FileListBox1Change(Sender: TObject);
begin
  FileListBox1.Hint := 'تعداد امضاها: ' + IntToStr (FileListBox1.Count) + #10#13 + 'کد انتخابی: ' + IntToStr (FileListBox1.ItemIndex + 1);
end;

procedure TForm3.FileListBox1Click(Sender: TObject);
var
  S, Name: string;
  NameLen, Temp: Integer;
begin
  //Label1.Caption := '';
  S := FileListBox1.FileName;
  Delete (S, 1, Length (FileListBox1.Directory) + 1);
  GroupBox1.Hint := Image1.Hint;
  //Form2.SpinEdit1.Value := StrToInt (Copy (S, 2, Length (S) - 4 - 2 + 1));
  Image1.Canvas.FillRect (Rect (0, 0, Image1.Width, Image1.Height));
  AssignFile (F, FileListBox1.FileName);
  Reset (F);
  Name := '';
  read(F, NameLen);
  for i := 1 to NameLen - 1 do
  begin
    read(F, temp);
    Name := Name + Char(temp);
  end;
  Readln(F, temp);
  Name := Name + Char(temp);
  Image1.Hint := 'نام صاحب: ' + Name;
  Form2.SpinEdit1.Value := StrToInt(Copy (S, 1, Length (S) - 4));
  Form2.Edit1.Text := Name;
  Readln (F);
  I := 0;
  while not EOF (F) do
  begin
    Inc (I);
    Read (F, Pnt[I].X);
    Readln (F, Pnt[I].Y);
  end;
  CloseFile (F);
  Image1.Canvas.Pen.Width := PenSize;
  Image1.Canvas.Pen.Color := PenColor;
  Image1.Canvas.MoveTo (Pnt[1].X, Pnt[1].Y);
  Image1.Canvas.LineTo (Pnt[1].X, Pnt[1].Y);
  M := 0;
  J := 0;
  Timer1.Enabled := True;
end;

procedure TForm3.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  for I := 1 to 4 do
    B[I] := True;
end;

procedure TForm3.GroupBox2Click(Sender: TObject);
begin
  FileListBox1.Update;
end;

procedure TForm3.Timer1Timer(Sender: TObject);
begin
  if J < I then
  begin
    Inc (J);
    if (Dis (Pnt[J].X, Pnt[J].Y, Pnt[J - 1].X, Pnt[J - 1].Y) <= D) and (J <> 1) then
      Image1.Canvas.LineTo (Pnt[J].X, Pnt[J].Y)
    else
    begin
      Inc (M);
      Image1.Canvas.TextOut (Pnt[J].X + 5, Pnt[J].Y + 2, IntToStr (M));
      Pt[1, M] := Pnt[J];
      Pt[2, M] := Pnt[J - 1];
    end;
    Image1.Canvas.MoveTo (Pnt[J].X, Pnt[J].Y);
  end
  else
  begin
    Image1.Canvas.Pen.Width := PenSize2;
    Image1.Canvas.Pen.Color := PenSColor;
    Image1.Canvas.MoveTo (Pnt[1].X, Pnt[1].Y);
    Image1.Canvas.LineTo (Pnt[1].X, Pnt[1].Y);
    Image1.Canvas.Pen.Color := PenFColor;
    Image1.Canvas.MoveTo (Pnt[I].X, Pnt[I].Y);
    Image1.Canvas.LineTo (Pnt[I].X, Pnt[I].Y);
    for K := 1 to M do
    begin
      if (Pt[1, K].X <> 0) and (Pt[1, K].Y <> 0) then
      begin
        Image1.Canvas.Pen.Color := PenSColor;
        Image1.Canvas.MoveTo (Pt[1, K].X, Pt[1, K].Y);
        Image1.Canvas.LineTo (Pt[1, K].X, Pt[1, K].Y);
      end;
      if (Pt[2, K].X <> 0) and (Pt[2, K].Y <> 0) then
      begin
        Image1.Canvas.Pen.Color := PenFColor;
        Image1.Canvas.MoveTo (Pt[2, K].X, Pt[2, K].Y);
        Image1.Canvas.LineTo (Pt[2, K].X, Pt[2, K].Y);
      end;
    end;
    Timer1.Enabled := False;
  end;
end;

end.

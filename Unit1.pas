unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, Math, Unit2, Unit3, Unit4, System.Types;

type
  TForm1 = class(TForm)
    Shape1: TShape;
    Label1: TLabel;
    Button1: TButton;
    Image1: TImage;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Timer1: TTimer;
    CheckBox1: TCheckBox;
    GroupBox1: TGroupBox;
    Memo1: TMemo;
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SetPoints (Image: TImage; var Point1, Point2: TPoint);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TCh = record
    S: string;
    Ch1: Char;
    Ch2: Char;
  end;

  TPerson = record
    Name: UTF8String;
    Count: Integer;
    Similarity: Real;
  end;
  PPerson = ^TPerson;

  TMouseState = record
    pos: TPoint;
    lastvalid: integer;
    down: boolean;
  end;

const
  PenColor = clBlue;
  PenSize = 3;
  D = 12;
  R = 10;
  Cha: array [1..4] of TCh = ((S: ''; Ch1: 'A'; Ch2: 'Z'), (S: '0'; Ch1: 'A'; Ch2: 'Z'), (S: '#'; Ch1: '0'; Ch2: '9'), (S: '$'; Ch1: '!'; Ch2: '/'));
  HashMod = 1048576;
  HashBase = 701;

var
  Form1: TForm1;
  J, J2, N, T, Angles, cnt1, cnt3, pntcnt: Integer;
  Count: Real;
  //B: array [0..10000 - 1] of Boolean;
  Pnt1: array [1..100000] of TPoint;
  Pnt2: array [1..100000] of TPoint;
  Pnt3: array [1..100000] of TPoint;
  //Pnt3: array [1..100, 1..100000] of TPoint;
  Point1, Point2, Last: TPoint;
  Angle, Ang: Real;
  //S: string;
  Persons: array [0..HashMod - 1] of TPerson;
  Similars: TList;
  MouseState: TMouseState;

implementation

{$R *.dfm}

function Dis (X1, Y1, X2, Y2: Real): Real;
begin
  Dis := Sqrt (Sqr (X2 - X1) + Sqr (Y2 - Y1));
end;

function ATan (xx, yy: Real): Real;
var
	xxx, yyy, Teta: Real;
begin
	xxx := Abs(xx);
  yyy := Abs(yy);
  if (xx >= 0) and (yy >= 0) and (xxx > yyy) then Teta := ArcTan (yyy / xxx);
  if (xx >= 0) and (yy >= 0) and (xxx < yyy) then Teta := Pi / 2 - ArcTan (xxx / yyy);
  if (xx >= 0) and (yy >= 0) and (xxx = yyy) then Teta := Pi / 4;
	if (xx <  0) and (yy >= 0) and (xxx > yyy) then Teta := Pi - ArcTan (yyy / xxx);
  if (xx <  0) and (yy >= 0) and (xxx < yyy) then Teta := Pi / 2 + ArcTan (xxx / yyy);
  if (xx <  0) and (yy >= 0) and (xxx = yyy) then Teta := Pi - Pi / 4;
	if (xx <  0) and (yy <  0) and (xxx > yyy) then Teta := Pi + ArcTan (yyy / xxx);
  if (xx <  0) and (yy <  0) and (xxx < yyy) then Teta := 3 * Pi / 2 - ArcTan (xxx / yyy);
	if (xx <  0) and (yy <  0) and (xxx = yyy) then Teta := Pi + Pi / 4;
  if (xx >= 0) and (yy <  0) and (xxx > yyy) then Teta := 2 * Pi - ArcTan (yyy / xxx);
	if (xx >= 0) and (yy <  0) and (xxx < yyy) then Teta := 3 * Pi / 2 + ArcTan (xxx / yyy);
  if (xx >= 0) and (yy <  0) and (xxx = yyy) then Teta := 2 * Pi - Pi / 4;
  ATan := Teta * 180 / Pi;
end;

procedure Swap(var x, y: Integer); overload;
var
  z: integer;
begin
  z := y;
  y := x;
  x := z;
end;

procedure Swap(var x, y: TPoint); overload;
var
  z: TPoint;
begin
  z := y;
  y := x;
  x := z;
end;

function Substract(a, b: TPoint): TPoint;
var
  c: TPoint;
begin
  c.X := a.X - b.X;
  c.Y := a.Y - b.Y;
  Substract := c;
end;

function getSize(a: TPoint): Real;
begin
  getSize := sqrt(sqr(a.X) + sqr(a.Y));
end;

(*procedure setSize(var a: TPoint);
var
  tmp: Real;
begin
  tmp := getSize(a);
  a.X := a.X / tmp;
  a.Y := a.Y / tmp;
end;*)

function StrHash(s: UTF8String): Integer;
var
  ret, i: Integer;
begin
  ret := 0;
  for i := 1 to Length(s) do
    ret := (((ret * HashBase) mod HashMod) + ord(s[i])) mod HashMod;
  StrHash := ret;
end;

function Compare(a, b: Pointer): Integer;
var
  p1, p2: TPerson;
begin
  p1 := PPerson(a)^;
  p2 := PPerson(b)^;
  if (p1.Similarity < p2.Similarity) then
    Compare := -1;
  if (p1.Similarity = p2.Similarity) then
    Compare := 0;
  if (p1.Similarity > p2.Similarity) then
    Compare := +1;
end;

procedure TForm1.SetPoints (Image: TImage; var Point1, Point2: TPoint);
var
  B1, B2, B3: Boolean;
  X, Y: Integer;
begin
  X := Image.Width - 1;
  Y := Image.Height - 1;
  B1 := True;
  B2 := True;
  B3 := True;
  Point2 := Point (0, 0);
  while B3 and (X >= 0) do
  begin
    Y := Image.Height - 1;
    while Y >= 0 do
    begin
      Dec (Y, 1);
      if B2 then
        if Image.Canvas.Pixels[X, Y] = PenColor then
        begin
          Point2.X := X;
          B2 := False;
        end;
      if B1 then
        if Image.Canvas.Pixels[Image.Width - X, Image.Height - Y] = PenColor then
        begin
          Point1.X := Image.Width - X;
          B1 := False;
        end;
      B3 := B1 or B2;
      if not B3 then
        break;
    end;
    Dec (X, 1);
  end;
  X := Image.Width - 1;
  Y := Image.Height - 1;
  B1 := True;
  B2 := True;
  B3 := True;
  while B3 and (Y >= 0) do
  begin
    X := Image.Width - 1;
    while X >= 0 do
    begin
      Dec (X, 1);
      if B2 then
        if Image.Canvas.Pixels[X, Y] = PenColor then
        begin
          Point2.Y := Y;
          B2 := False;
        end;
      if B1 then
        if Image.Canvas.Pixels[Image.Width - X, Image.Height - Y] = PenColor then
        begin
          Point1.Y := Image.Height - Y;
          B1 := False;
        end;
      B3 := B1 or B2;
      if not B3 then
        break;
    end;
    Dec (Y, 1);
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Inc(cnt1);
  Pnt1[cnt1] := MouseState.pos;
  if not MouseState.down then
    pnt1[cnt1] := Point(10000, 10000)
  else
    MouseState.lastvalid := cnt1;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  F: TextFile;
  I, Z, M, A, AA, Ch, C, Temp, NameLen, h, cnt2, co2: Integer;
  Cmp, Mn, Mx, distmp, Cmp2: Real;
  Name, Owner: UTF8String;
  v1, v2, v3: TPoint;
  p: TPerson;
begin
  Timer1.Enabled := false;
  cnt1 := MouseState.lastvalid;
  Label1.Caption := 'صاحب امضا: -';
  Inc (T);
  Label2.Caption := IntToStr (T);
  SetPoints (Image1, Point1, Point2);
  Count := 0;
  I := 0;
  cnt2 := 0;
  Mn := 1000000;
  AA := 1;
    while FileExists (IntToStr (AA) + '.txt') do
      Inc (AA);
  for i := 0 to HashMod - 1 do
  begin
    Persons[i].Count := 0;
    Persons[i].Similarity := 1000000;
  end;
  for Ch := 1 to AA - 1 do
  begin
    A := 1;
    AssignFile (F, IntToStr (Ch) + '.txt');
    Reset (F);
    I := 0;
    cnt2 := 0;
    Name := '';
    read(F, NameLen);
    for i := 1 to NameLen - 1 do
    begin
      read(F, temp);
      Name := Name + Char(temp);
    end;
    Readln(F, temp);
    Name := Name + Char(temp);
    h := StrHash(Name);
    Readln (F, M);

    while not EOF (F) do
    begin
      Inc (cnt2);
      Read (F, Pnt2[cnt2].X);
      Readln (F, Pnt2[cnt2].Y);
    end;
    cnt3 := cnt1;
    for i := 1 to cnt1 do
      pnt3[i] := pnt1[i];
    if (cnt2 < cnt1) then
    begin
      for i := 1 to cnt1 do
        swap(pnt1[i], pnt2[i]);
      swap(cnt1, cnt2);
    end;
    Cmp := 0;
    Ang := 0;
    Mx := Max (J, I);
    for z := 1 to cnt1 do
    begin
      distmp := Dis (Pnt1[z].X - Point1.X, Pnt1[z].Y - Point1.Y,
      Pnt2[Trunc (1 + (Z - 1) * cnt2 / (cnt1 + 0.0))].X, Pnt2[Trunc (1 + (Z - 1) * cnt2 / (cnt1 + 0.0))].Y);
      if distmp > 1000 then
        distmp := 100;
      if ((Pnt1[z].X > 1000) and (Pnt2[Trunc (1 + (Z - 1) * cnt2 / (cnt1 + 0.0))].X > 1000)) then
        distmp := 0;
      Cmp := Cmp + distmp;
    end;
    co2 := 0;
    Cmp2 := 0;
    for z := 2 to cnt1 do
    begin
      if ((Pnt1[z].X <= 1000) and (Pnt1[z - 1].X <= 1000)) then
      if (Pnt2[Trunc (1 + (Z - 1) * cnt2 / (cnt1 + 0.0))].X <= 1000) then
      if (Pnt2[Trunc (1 + (Z - 1) * cnt2 / (cnt1 + 0.0)) - 1].X <= 1000) then
      begin
        v1 := Substract(Pnt1[z], Pnt1[z - 1]);
        v2 := Substract(Pnt2[Trunc (1 + (Z - 1) * cnt2 / (cnt1 + 0.0))], Pnt2[Trunc (1 + (Z - 1) * cnt2 / (cnt1 + 0.0)) - 1]);
        //setSize(v1);
        //setSize(v2);
        v3 := Substract(v2, v1);
        Cmp2 := Cmp2 + getSize(v3) * 10;
        Inc(co2);
      end;
    end;
    Cmp := (Cmp / cnt1) + (Cmp2 / co2);
    Persons[h].Name := Name;
    Persons[h].Similarity := (Persons[h].Similarity * Persons[h].Count + Cmp) / (Persons[h].Count + 1);
    Inc(Persons[h].Count);
    cnt1 := cnt3;
    for i := 1 to cnt1 do
      pnt1[i] := pnt3[i];
    (*for Z := 1 to Min (J, I) do
    begin
      Cmp := Cmp + Dis (Pnt1[Round (Z * Mx / I)].X - Point1.X, Pnt1[Round (Z * Mx / I)].Y - Point1.Y,
      Pnt2[Ch, Round (Z * Mx / J)].X, Pnt2[Ch, Round (Z * Mx / J)].Y);
      if Z > 1 then
      begin
        Ang := Ang + Abs (ATan (Pnt1[Round (Z * Mx / I)].X - Pnt1[Round (Z * Mx / I - 1)].X, Pnt1[Round (Z * Mx / I)].Y - Pnt1[Round (Z * Mx / I - 1)].Y)
        - ATan (Pnt2[Ch, Round (Z * Mx / J)].X - Pnt2[Ch, Round (Z * Mx / J - 1)].X, Pnt2[Ch, Round (Z * Mx / J)].Y - Pnt2[Ch, Round (Z * Mx / J - 1)].Y));
      end;
      Cmp := Cmp / {Mx}I + Abs (N - M) * 12.5;
      Cmp := Cmp + Ang / I / 1.5;
      Label4.Caption := FloatToStr (Ang / I / 1.5);
      //Cmp := Cmp + Abs (I - J);
      Persons[h].Name := Name;
      Persons[h].Similarity := (Persons[h].Similarity * Persons[h].Count + Cmp) / (Persons[h].Count + 1);
      Inc(Persons[h].Count);
//      if Cmp < Mn then
//      begin
//        Mn := Cmp;
//        Owner := Name;
//      end;
      //Label6.Caption := Label6.Caption  + Ch + ' ' + IntToStr (Round (Cmp)){ + ' ' + IntToStr (J)} + #10#13;
      //CloseFile (F);
      Inc (A);
    end;*)
  end;
  for i := 0 to HashMod - 1 do
    if (Persons[i].Similarity < Mn) then
    begin
      Mn := Persons[i].Similarity;
      Owner := Persons[i].Name;
    end;
  Memo1.Clear;
  Similars := TList.Create;
  Similars.Clear;
  for i := 0 to HashMod - 1 do
      if (Persons[i].Count > 0) then
        Similars.Add(@Persons[i]);
  Similars.Sort(Compare);
  for i := 0 to Similars.Count - 1 do
  begin
    p := PPerson(Similars[i])^;
    Memo1.Lines.Add(p.Name + ': ' + FloatToStr(2000 - p.Similarity));
  end;
  Similars.Free;
  //Label2.Caption := IntToStr (Point1.X) + ' ' + IntToStr (Point1.Y);
  //Label3.Caption := IntToStr (Point2.X) + ' ' + IntToStr (Point2.Y);
  Image1.Canvas.FillRect (Rect (0, 0, Image1.Width, Image1.Height));
  Label1.Caption := 'صاحب امضا: ' + Owner;
  cnt1 := 0;
  N := 0;
  pntcnt := 0;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Form2.Show;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Form3.Show;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Image1.Canvas.FillRect (Rect (0, 0, Image1.Width, Image1.Height));
  cnt1 := 0;
  N := 0;
  Angle := 0;
  Angles := 0;
  Label3.Caption := '0';
  Timer1.Enabled := False;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  Form4.Show;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  if (CheckBox1.Checked) then
    Form1.Width := 480
  else
    Form1.Width := 216;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Image1.Canvas.Pen.Width := PenSize;
  Image1.Canvas.Pen.Color := PenColor;
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Image1.Canvas.MoveTo (X, Y);
  Image1.Canvas.LineTo (X, Y);
  Image1.Canvas.Ellipse (X - 1, Y - 1, X + 1, Y + 1);
  Inc (N);
  (*Count := 0;
  Inc (cnt1);
  Pnt1[cnt1] := Point (X, Y);
  Last := Point (X, Y);*)
  //Label6.Caption := IntToStr (N);
  MouseState.pos := Point(x, y);
  MouseState.down := SSLeft in Shift;
  if MouseState.down then
    Timer1.Enabled := True;
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  //Label4.Caption := IntToStr (X) + ' ' + IntToStr (Y);
  MouseState.pos := Point(x, y);
  MouseState.down := SSLeft in Shift;
  if MouseState.down then
  begin
    Timer1.Enabled := True;
    Image1.Canvas.LineTo (X, Y);
  end;
  (*if SSLeft in Shift then
  begin
    {if (Count mod D = 0) or ((not B[Count div D]) and (Count > (Count div D) * Count)) then
    begin
      Pnt1[(Count div D) + 1].X := X;
      Pnt1[(Count div D) + 1].Y := Y;
      B[Count div D] := True;
      Image1.Canvas.Ellipse (X - 3, Y - 3, X + 3, Y + 3);
      Label5.Caption := IntToStr (Count) + ' ' + IntToStr (X) + ' ' + IntToStr (Y);
      Count := Count mod D;
    end;
    Inc (Count);}
    Image1.Canvas.LineTo (X, Y);
    if Count >= D then
    begin
      Inc (cnt1);
      Pnt1[cnt1] := Point (X, Y);
      //Image1.Canvas.Ellipse (X - 3, Y - 3, X + 3, Y + 3);
      Count := 0;
      //Count := Count mod D;
      //Label5.Caption := IntToStr (Count) + ' ' + IntToStr (X) + ' ' + IntToStr (Y);
    end;
    if Count < D then
      Count := Count + Dis (Last.X, Last.Y, X, Y);
    if (cnt1 > 1) and (Count >= D) then
      if Abs (ATan (X - Last.X, Y - Last.Y) - Angle) > 87.5 then
      begin
        Inc (Angles);
        Label3.Caption := IntToStr (Angles);
      end;
    //Label3.Caption := FloatToStr (ATan (X - Last.X, Y - Last.Y)) + ' ' + FloatToStr (Angle);
    if Count >= D then
      Angle := ATan (X - Last.X, Y - Last.Y);
    Last := Point (X, Y);
  end;*)
end;

end.

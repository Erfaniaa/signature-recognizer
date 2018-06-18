unit Unit4;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Math, Spin, Grids;

type
  TForm4 = class(TForm)
    Image2: TImage;
    Shape1: TShape;
    Button1: TButton;
    Label1: TLabel;
    Label3: TLabel;
    Button2: TButton;
    Shape2: TShape;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    procedure Image2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SetPoints (Image: TImage; var Point1, Point2: TPoint);
    procedure Button2Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure CheckBox4Click(Sender: TObject);
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

const
  PenColor = clBlue;
  PenSize = 4;
  D = 12;
  R = 10;
  Cha: array [1..4] of TCh = ((S: ''; Ch1: 'A'; Ch2: 'Z'), (S: '0'; Ch1: 'A'; Ch2: 'Z'), (S: '#'; Ch1: '0'; Ch2: '9'), (S: '$'; Ch1: '!'; Ch2: '/'));

var
  Form4: TForm4;
  T, Co: Integer;
  Count: Real;
  Pnt1: array [1..100, 1..10000] of TPoint;
  Pnt2: array ['A'..'Z', 1..10000] of TPoint;
  Pnt3: array [1..100, 1..100000] of TPoint;
  N, J, P: array [1..100] of Integer;
  Point1, Point2, Last: TPoint;
  Ang: Real;
  ChB: array [1..4] of Boolean;
  DX: Integer;

implementation

{$R *.dfm}

function Dis (X1, Y1, X2, Y2: Real): Real;
begin
  Dis := Sqrt (Sqr (X2 - X1) + Sqr (Y2 - Y1));
end;

function ATan (xx, yy: Real): Real;
var
	xxx, yyy, Teta: Extended;
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

procedure TForm4.SetPoints (Image: TImage; var Point1, Point2: TPoint);
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

procedure TForm4.Button1Click(Sender: TObject);
var
  Ch: Char;
  C: string[10];
  F: TextFile;
  I, Z, M, A, B, CC, CN: Integer;
  Cmp, Mn, Mx, AY: Real;
  Cpt: string;
begin
  {for I := 0 to 100 do
    B[I] := false;}
  //Label6.Caption := '';
  //Inc (T);
  Label3.Caption := '';
  //Label2.Caption := IntToStr (T);
  Count := 0;
  I := 0;
  for B := 1 to Co do
  begin
    SetPoints (Image2, Point1, Point2);
    //Label2.Caption := IntToStr (Point1.X) + ' ' + IntToStr (Point1.Y);
    Mn := 100000;
    for CN := 1 to 4 do
    begin
      {AY := 0;
      for I := 1 to J[B] do
        AY := AY + Pnt1[B, I].Y;
      AY := AY / J[B];}
      {CN := 1;
      if AY > 95 then
        CN := 2;}
      if ChB[CN] then
      begin
        for Ch:= Cha[CN].Ch1 to Cha[CN].Ch2 do
        begin
          A := 1;
          while FileExists (Cha[CN].S + Ch + IntToStr (A) + '.txt') do
          begin
            AssignFile (F, Cha[CN].S + Ch + IntToStr (A) + '.txt');
            Reset (F);
            I := 0;
            Readln (F, M);
            while not EOF (F) do
            begin
              Inc (I);
              Read (F, Pnt2[Ch, I].X);
              Readln (F, Pnt2[Ch, I].Y);
            end;
            Cmp := 0;
            Ang := 0;
            Mx := Max (J[B], I);
            for Z := 1 to Min (J[B], I) do
            begin
              Cmp := Cmp + Dis (Pnt1[B, Round (Z * Mx / I)].X - Point1.X, Pnt1[B, Round (Z * Mx / I)].Y - Point1.Y,
              Pnt2[Ch, Round (Z * Mx / J[B])].X, Pnt2[Ch, Round (Z * Mx / J[B])].Y);
              if Z > 1 then
              begin
                Ang := Ang + Abs (ATan (Pnt1[B, Round (Z * Mx / I)].X - Pnt1[B, Round (Z * Mx / I - 1)].X, Pnt1[B, Round (Z * Mx / I)].Y - Pnt1[B, Round (Z * Mx / I - 1)].Y)
                - ATan (Pnt2[Ch, Round (Z * Mx / J[B])].X - Pnt2[Ch, Round (Z * Mx / J[B] - 1)].X, Pnt2[Ch, Round (Z * Mx / J[B])].Y - Pnt2[Ch, Round (Z * Mx / J[B] - 1)].Y));
              end;
            end;
            Cmp := Cmp / I + Abs (N[B] - M) * 7.5;
            Cmp := Cmp + Ang / I / 1.5;
            //Cmp := Cmp + Abs (I - J);
            if Cmp < Mn then
            begin
              Mn := Cmp;
              C := Ch;
              if CN = 2 then
                C := LowerCase (C)[1];
              //C := C + IntToStr (A);
            end;
            //Label6.Caption := Label6.Caption  + Ch + ' ' + IntToStr (Round (Cmp)){ + ' ' + IntToStr (J)} + #10#13;
            CloseFile (F);
            Inc (A);
          end;
        end;
      end;
    end;
    Label3.Caption := Label3.Caption + C;
    {Cpt := Label3.Caption;
    if (C = 'H') and (Label3.Caption[Length (Label3.Caption) - 1] = 'I') then
      Delete (Cpt, Length (Label3.Caption) - 1, 1);
    Label3.Caption := Cpt;}
    Image2.Canvas.Pen.Width := PenSize + 4;
    Image2.Canvas.Pen.Color := clWhite;
    Image2.Canvas.MoveTo (Pnt3[B, 1].X, Pnt3[B, 1].Y);
    for CC := 1 to P[B] do
    begin
      Image2.Canvas.LineTo (Pnt3[B, CC].X, Pnt3[B, CC].Y);
      Image2.Canvas.FillRect (Rect (Pnt3[B, CC].X - 8, Pnt3[B, CC].Y - 8, Pnt3[B, CC].X + 8, Pnt3[B, CC].Y + 8));
      Image2.Canvas.MoveTo (Pnt3[B, CC].X, Pnt3[B, CC].Y);
    end;
    Image2.Canvas.FillRect (Rect (Pnt3[B, 1].X - 8, Pnt3[B, 1].Y - 8, Pnt3[B, 1].X + 8, Pnt3[B, 1].Y + 8));
    Image2.Canvas.FillRect (Rect (Pnt3[B, P[B]].X - 8, Pnt3[B, P[B]].Y - 8, Pnt3[B, P[B]].X + 8, Pnt3[B, P[B]].Y + 8));
    Image2.Canvas.Pen.Width := PenSize;
    Image2.Canvas.Pen.Color := PenColor;
  end;
  //Label2.Caption := IntToStr (Point1.X) + ' ' + IntToStr (Point1.Y);
  //Label3.Caption := IntToStr (Point2.X) + ' ' + IntToStr (Point2.Y);
  Image2.Canvas.FillRect (Rect (0, 0, Image2.Width, Image2.Height));
  //Label1.Caption := 'Character: ' + C;
  for B := 1 to 100 do
  begin
    J[B] := 0;
    N[B] := 0;
    P[B] := 0;
  end;
  Co := 0;
end;

procedure TForm4.Button2Click(Sender: TObject);
var
  B: Integer;
begin
  Image2.Canvas.FillRect (Rect (0, 0, Image2.Width, Image2.Height));
  Count := 0;
  for B := 1 to 100 do
  begin
    J[B] := 0;
    N[B] := 0;
    P[B] := 0;
  end;
  Co := 0;
end;

procedure TForm4.CheckBox1Click(Sender: TObject);
begin
  ChB[1] := CheckBox1.Checked;
  if CheckBox1.Checked and (CheckBox3.Checked or CheckBox4.Checked) then
  begin
    CheckBox3.Checked := False;
    CheckBox3.Checked := False;
  end;
  if CheckBox1.Checked then
    DX := 50;
end;

procedure TForm4.CheckBox2Click(Sender: TObject);
begin
  ChB[2] := CheckBox2.Checked;
  if CheckBox2.Checked and (CheckBox3.Checked or CheckBox4.Checked) then
  begin
    CheckBox3.Checked := False;
    CheckBox3.Checked := False;
  end;
  if CheckBox2.Checked then
    DX := 50;
end;

procedure TForm4.CheckBox3Click(Sender: TObject);
begin
  ChB[3] := CheckBox3.Checked;
  if CheckBox3.Checked then
  begin
    CheckBox1.Checked := False;
    CheckBox2.Checked := False;
    CheckBox4.Checked := False;
    DX := -10000;
  end;
end;

procedure TForm4.CheckBox4Click(Sender: TObject);
begin
  ChB[4] := CheckBox4.Checked;
  if CheckBox4.Checked then
  begin
    CheckBox1.Checked := False;
    CheckBox2.Checked := False;
    CheckBox3.Checked := False;
  end;
  if CheckBox4.Checked then
    DX := 45;
end;

procedure TForm4.FormCreate(Sender: TObject);
begin
  Image2.Canvas.Pen.Width := PenSize;
  Image2.Canvas.Pen.Color := PenColor;
  Image2.Canvas.FillRect (Rect (0, 0, Image2.Width, Image2.Height));
  CheckBox1.Checked := True;
  CheckBox2.Checked := True;
  DX := 50;
end;

procedure TForm4.Image2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Image2.Canvas.MoveTo (X, Y);
  Image2.Canvas.LineTo (X, Y);
  Image2.Canvas.Ellipse (X - 1, Y - 1, X + 1, Y + 1);
  if Co = 0 then
    Inc (Co)
  else
    if (X - Last.X > DX) {(Dis (Pnt1[Co, 1].X, Pnt1[Co, 1].Y, X, Y) > DX)} then
      Inc (Co);
  //Caption := IntToStr (Co) + ' ' + IntToStr (X - Last.X);
  Count := 0;
  Inc (J[Co]);
  Inc (N[Co]);
  Inc (P[Co]);
  Pnt1[Co, J[Co]] := Point (X, Y);
  Last := Point (X, Y);
  //Label6.Caption := IntToStr (N);
end;

procedure TForm4.Image2MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  //Label4.Caption := IntToStr (X) + ' ' + IntToStr (Y);
  if SSLeft in Shift then
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
    Image2.Canvas.LineTo (X, Y);
    if Count >= D then
    begin
      Inc (J[Co]);
      Pnt1[Co, J[Co]] := Point (X, Y);
      //Image1.Canvas.Ellipse (X - 3, Y - 3, X + 3, Y + 3);
      Count := 0;
      //Count := Count mod D;
      //Label5.Caption := IntToStr (Count) + ' ' + IntToStr (X) + ' ' + IntToStr (Y);
    end;
    if Count < D then
      Count := Count + Dis (Last.X, Last.Y, X, Y);
    Last := Point (X, Y);
    Inc (P[Co]);
    Pnt3[Co, P[Co]] := Last;
  end;
end;

end.

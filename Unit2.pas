unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Spin;

type
  TForm2 = class(TForm)
    Image1: TImage;
    Shape1: TShape;
    Button1: TButton;
    Edit1: TEdit;
    Button2: TButton;
    Label1: TLabel;
    SpinEdit1: TSpinEdit;
    Label2: TLabel;
    Timer1: TTimer;
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Button1Click(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure SetPoints (Image: TImage; var Point1, Point2: TPoint);
    procedure Button2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

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

var
  Form2: TForm2;
  J, N, A, cnt1: Integer;
  S: string;
  Count: Real;
  B: array [0..10000 - 1] of Boolean;
  Pnt: array [1..10000] of TPoint;
  Point1, Point2, Last: TPoint;
  MouseState: TMouseState;

implementation

{$R *.dfm}

function Dis (X1, Y1, X2, Y2: Real): Real;
begin
  Dis := Sqrt (Sqr (X2 - X1) + Sqr (Y2 - Y1));
end;

procedure TForm2.SetPoints (Image: TImage; var Point1, Point2: TPoint);
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

procedure TForm2.Timer1Timer(Sender: TObject);
begin
  Inc(cnt1);
  Pnt[cnt1] := MouseState.pos;
  if not MouseState.down then
    pnt[cnt1] := Point(10000, 10000)
  else
    MouseState.lastvalid := cnt1;
end;

procedure TForm2.Button1Click(Sender: TObject);
var
  F: TextFile;
  I: Integer;
  Temp: Byte;
begin
  if Trim (Edit1.Text) <> '' then
  begin
    Timer1.Enabled := False;
    cnt1 := MouseState.lastvalid;
    SetPoints (Image1, Point1, Point2);
    Edit1.Text := Trim (Edit1.Text);
    A := SpinEdit1.Value;
    AssignFile (F, IntToStr (A) + '.txt');
    if FileExists (IntToStr (A) + '.txt') then
      FileSetAttr (IntToStr (A) + '.txt', faNormal);
    Rewrite (F);
    //for Temp in TEncoding.UTF8.GetPreamble do write(F, AnsiChar(Temp));
    write (F, Length(Edit1.Text), ' ');
    for i := 1 to Length(Edit1.Text) - 1 do
      write (F, Ord(Edit1.Text[i]), ' ');
    Writeln (F, Ord(Edit1.Text[Length(Edit1.Text)]));
    Writeln (F, N);
    for I := 1 to cnt1 do
    begin
      Writeln (F, Pnt[I].X - Point1.X, ' ', Pnt[I].Y - Point1.Y);
    end;
    CloseFile (F);
    FileSetAttr (IntToStr (A) + '.txt', faHidden);
    J := 0;
    cnt1 := 0;
    N := 0;
    Image1.Canvas.FillRect (Rect (0, 0, Image1.Width, Image1.Height));
    //Form3.FileListBox1.Update;
  end;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  Image1.Canvas.FillRect (Rect (0, 0, Image1.Width, Image1.Height));
  J := 0;
  cnt1 := 0;
  N := 0;
  Timer1.Enabled := False;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  Image1.Canvas.Pen.Width := PenSize;
  Image1.Canvas.Pen.Color := PenColor;
  Edit1.Text := 'نام و نام خانوادگی';
  A := 1;
    while FileExists (IntToStr (A) + '.txt') do
      Inc (A);
  SpinEdit1.Value := A;
end;

procedure TForm2.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Image1.Canvas.MoveTo (X, Y);
  Image1.Canvas.LineTo (X, Y);
  Image1.Canvas.Ellipse (X - 1, Y - 1, X + 1, Y + 1);
  Inc (N);
  (*Count := 0;
  Inc (J);
  Pnt[J] := Point (X, Y);
  Last := Point (X, Y);
  //Label6.Caption := IntToStr (N);*)
  MouseState.pos := Point(x, y);
  MouseState.down := SSLeft in Shift;
  if MouseState.down then
    Timer1.Enabled := True;
end;

procedure TForm2.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
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
      Inc (J);
      Pnt[J] := Point (X, Y);
      B[J] := True;
      //Image1.Canvas.Ellipse (X - 3, Y - 3, X + 3, Y + 3);
      Count := 0;
      //Count := Count mod D;
    end;
    if Count < D then
      Count := Count + Dis (Last.X, Last.Y, X, Y);
    Last := Point (X, Y);
  end;*)
end;

end.

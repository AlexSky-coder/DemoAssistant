unit uDemoAssistant;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, StrUtils, Math;

type
  Twit = (Wint, Wfloat, Wfloat_ns, Wip4, Wip6, Wbip4, Wtime, Wdate, WDateTime,
    Wcom, Wexpression, Wstr);

type
  TipV4 = array[0..3] of byte;
  TipV6 = array[0..7] of word;

type

  { TDemoAssistant }

  TDemoAssistant = class(TObject)
  public
    constructor Create;
    destructor Destroy; override;
    procedure run;

  private
    FormatSettings: TFormatSettings;
    procedure input(out s: string);
    function whatIsIt(const s: string; out i: int64; out f: double;
      out ip4: TipV4; out ip6: TipV6): Twit;
    function TryStrToIpV4(const s: string; out ip4: TipV4): boolean;
    function TryStrToIpV6(const s: string; out ip6: TipV6): boolean;
    function TryBinToIPV4(const s: string; out ip4: TipV4): boolean;
    function TryBinToInt(const s: string; out i: int64): boolean;
    function TryNSToFloat(const s: string; out f: double): boolean;
    function floatToBin(f: double): string;
    function ipToBin(ip4: TipV4): string;
    function ipToBin(ip6: TipV6): string; overload;
    function ipToStr(ip4: TipV4): string;
    function strToBin(s: string): string;
    function tryCom(s: string): boolean;
    function u8a(s: string): string;
    function nToNsys(num: double; base: integer): string;
    procedure com(s: string);
    procedure help;
    procedure demo;
    procedure twoIp4;
    procedure maskIp4;
    procedure BToI;
    procedure numToNS;
    procedure PrintFloat;
    function mulstr(s: string; Count: integer): string;
    function CountChar(const str: string; const ch: string): integer;
  end;

implementation

{ TuDemoAssistant }

constructor TDemoAssistant.Create;
begin
  FormatSettings := DefaultFormatSettings;
  FormatSettings.DecimalSeparator := ',';
  writeln(u8a('Введите "help".'));
end;

destructor TDemoAssistant.Destroy;
begin
  inherited Destroy;
end;

procedure TDemoAssistant.run;
var
  exitCode: integer = 0;
  inp: string;
  i: int64;
  f: double;
  ip4: TipV4;
  ip6: TipV6;
begin
  while exitCode = 0 do
  begin
    input(inp);
    if inp <> '' then
      case whatIsIt(inp, i, f, ip4, ip6) of
        Twit.Wint: writeln(intToBin(i, 64));
        Twit.Wfloat: writeln(floatToBin(f));
        Twit.Wfloat_ns: writeln(FloatToStr(f));
        Twit.Wip4: writeln(ipToBin(ip4));
        Twit.Wbip4: writeln(ip4[0], '.', ip4[1], '.', ip4[2], '.', ip4[3]);
        Twit.Wip6: writeln(ipToBin(ip6));
        Twit.Wtime: writeln(floatToStr(f));
        Twit.Wdate: writeln(floatToStr(f));
        Twit.WDateTime: writeln(floatToStr(f));
        Twit.Wcom: com(inp);
        Twit.Wstr: writeln(strToBin(AnsiToUtf8(inp)));
      end;
  end;
end;

procedure TDemoAssistant.input(out s: string);
begin
  Write('>>');
  readln(s);
end;

function TDemoAssistant.whatIsIt(const s: string; out i: int64;
  out f: double; out ip4: TipV4; out ip6: TipV6): Twit;
begin
  if TryStrToInt64(s, i) then Result := Twit.Wint
  else
  if TryStrToFloat(s, f) then Result := Twit.Wfloat
  else
  if TryNSToFloat(s, f) then Result := Twit.Wfloat_ns
  else
  if TryStrToTime(s, f) then Result := Twit.Wtime
  else
  if TryStrToDate(s, f) then Result := Twit.Wdate
  else
  if TryStrToDateTime(s, f) then Result := Twit.WDateTime
  else
  if TryBinToIPV4(s, ip4) then  Result := Twit.Wbip4
  else
  if TryStrToIpV4(s, ip4) then  Result := Twit.Wip4
  else
  if TryStrToIpV6(s, ip6) then  Result := Twit.Wip6
  else
  if tryCom(s) then
    Result := Twit.Wcom
  else
    Result := Twit.Wstr;
end;

function TDemoAssistant.TryStrToIpV4(const s: string; out ip4: TipV4): boolean;
var
  np, i, n: integer;
  ss: string;
begin
  np := WordCount(s, ['.']);
  if np = 4 then
  begin
    Result := True;
    for i := 0 to 3 do
    begin
      ss := ExtractWord(i + 1, s, ['.']);
      if TryStrToInt(ss, n) then
      begin
        if (n < 0) or (n > 255) then
        begin
          Result := False;
          Break;
        end
        else
          ip4[i] := n;
      end
      else
      begin
        Result := False;
        Break;
      end;
    end;
  end
  else
    Result := False;
end;

function TDemoAssistant.TryStrToIpV6(const s: string; out ip6: TipV6): boolean;
var
  parts: TStringArray;
  i, n: Integer;
begin
  Result := False;
  parts := s.Split([':']);
  if Length(parts) <> 8 then Exit;

  for i := 0 to 7 do
  begin
    if not TryStrToInt('$' + parts[i], n) then Exit;
    ip6[i] := n;
  end;
  Result := True;
end;

function TDemoAssistant.TryBinToIPV4(const s: string; out ip4: TipV4): boolean;
var
  np, i, n: integer;
  ss: string;
  p, pp, bz, b1: integer;
begin
  p := CountChar(s, '.');
  pp := CountChar(s, '..');
  bz := CountChar(s, '0');
  b1 := CountChar(s, '1');

  if (b1 + bz + p = Length(s)) and (pp = 0) and (p = 3) then
  begin
    np := WordCount(s, ['.']);
    if np = 4 then
    begin
      Result := True;
      for i := 0 to 3 do
      begin
        ss := ExtractWord(i + 1, s, ['.']);
        if (TryStrToInt('%' + ss, n)) and (Length(ss) = 8) and
          ((n >= 0) and (n <= 255)) then
        begin
          ip4[i] := n;
        end
        else
        begin
          Result := False;
          Break;
        end;
      end;
    end
    else
      Result := False;
  end
  else
    Result := False;
end;

function TDemoAssistant.TryBinToInt(const s: string; out i: int64): boolean;
begin
  Result := False;
  if Length(s) = 0 then Exit;
  try
    if (s[1] = '%') and (CountChar(s, '0') + CountChar(s, '1') + 1 = Length(s)) then
    begin
      i := StrToInt(s);
      Result := True;
    end;
  except
    on E: Exception do
      Result := False;
  end;
end;

function TDemoAssistant.TryNSToFloat(const s: string; out f: double): boolean;
const
  al: array[0..35] of char = ('0', '1', '2', '3', '4', '5', '6', '7', '8',
    '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L',
    'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z');
var
  p, np, o, i, e: integer;
  ss: string;
begin
  p := CountChar(s, '_');
  np := WordCount(s, ['_']);
  Result := True;

  if (p = 1) and (np = 2) and (s <> '') then
  begin
    if (TryStrToInt(ExtractWord(2, s, ['_']), o)) and
      ((o >= 2) and (o <= Length(al))) then
    begin
      f := 0.0;
      ss := ExtractWord(1, s, ['_']);
      ss := ReplaceStr(ss, '.', ',');

      e := pos(',', ss) - 2;
      if CountChar(ss, ',') = 0 then
        e := Length(ss) - 1;

      for i := 1 to Length(ss) do
      begin
        if ss[i] = ',' then
          Continue;

        p := pos(ss[i], al) - 1;

        if (p < o) and (p >= 0) then
        begin
          f := f + p * Power(o, e);
          Dec(e);
          Result := True;
        end
        else
        begin
          Result := False;
          Break;
        end;
      end;
    end
    else
      Result := False;
  end
  else
    Result := False;
end;

function TDemoAssistant.floatToBin(f: double): string;
type
  TArrReal = packed array[0..7] of byte;
var
  i: integer;
  bytes: TArrReal = (0, 0, 0, 0, 0, 0, 0, 0);
begin
  Result := '';
  i := sizeof(f);
  move(f, bytes, i);
  for i := low(bytes) to High(bytes) do
  begin
    Result := intToBin(bytes[i], 8) + Result;
  end;
end;

function TDemoAssistant.ipToBin(ip4: TipV4): string;
begin
  Result := intToBin(ip4[0], 8) + '.' + intToBin(ip4[1], 8) + '.' +
    intToBin(ip4[2], 8) + '.' + intToBin(ip4[3], 8);
end;

function TDemoAssistant.ipToBin(ip6: TipV6): string;
begin
  Result :=
    intToBin(ip6[0], 16) + ':' + intToBin(ip6[1], 16) + ':' +
    intToBin(ip6[2], 16) + ':' + intToBin(ip6[3], 16) + ':' +
    intToBin(ip6[4], 16) + ':' + intToBin(ip6[5], 16) + ':' +
    intToBin(ip6[6], 16) + ':' + intToBin(ip6[7], 16);
end;

function TDemoAssistant.ipToStr(ip4: TipV4): string;
begin
  Result := IntToStr(ip4[0]) + '.' + IntToStr(ip4[1]) + '.' +
    IntToStr(ip4[2]) + '.' + IntToStr(ip4[3]);
end;

procedure TDemoAssistant.numToNS;
const
  al: array[0..35] of char = ('0', '1', '2', '3', '4', '5', '6', '7', '8',
    '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L',
    'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z');
var
  number: double;
  np, i, o: integer;
  s, ss: string;
begin
  repeat
    Write(u8a('Введите десятичное число:'));
    readln(s);
    s := ReplaceStr(s, '.', ',');
  until TryStrToFloat(s, number, FormatSettings);

  Write(u8a('Введите основания (2-' + IntToStr(Length(al)) + '):'));

  ReadLn(s);
  writeln(u8a('осн| число'));
  np := WordCount(s, [' ']);
  for i := 1 to np do
  begin
    ss := ExtractWord(i, s, [' ']);
    if TryStrToInt(ss, o) then
      WriteLn(o: 3, '| ', nToNsys(number, o));
  end;
end;

procedure TDemoAssistant.BToI;
var
  s: string;
begin
  Write(u8a('Введите двоичное число: '));
  ReadLn(s);
  writeln(StrToInt('%' + s));
end;

procedure TDemoAssistant.PrintFloat;
var
  s: string;
begin
  Write(u8a('Введите вещественное число: '));
  ReadLn(s);
  s := ReplaceStr(s, '.', ',');
  s := floatToBin(StrToFloat(s));
  Insert(' ', s, 13);
  Insert(' ', s, 2);
  writeln(s);
end;


function TDemoAssistant.strToBin(s: string): string;
var
  i: integer;
begin
  Result := '';
  for i := low(s) to High(s) do
  begin
    Result := Result + intToBin(Ord(s[i]), 8) + ' ';
  end;
end;

function TDemoAssistant.tryCom(s: string): boolean;
begin
  case s of
    'demo', '2ip4', 'mask', 'help', 'bin', 'float', 'nsys': Result := True;
    else
      Result := False;
  end;
end;

function TDemoAssistant.u8a(s: string): string;
begin
  Result := Utf8ToAnsi(s);
end;

function TDemoAssistant.nToNsys(num: double; base: integer): string;
const
  al: array[0..35] of char = ('0', '1', '2', '3', '4', '5', '6', '7', '8',
    '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L',
    'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z');
var
  p: double;
  exponent, digit: integer;
begin
  if base < 2 then
  begin
    Result := '';
    exit;
  end;

  if num = 0.0 then
  begin
    Result := '0';
    exit;
  end
  else
    Result := '';

  if num < 0.0 then
  begin
    Result := '-';
    num := abs(num);
  end;

  exponent := trunc(max(Floor(LogN(base, num)), 0.0));

  while (num > 5.5511151231257827E-017) or (exponent >= 0) do
  begin
    p := Power(base, exponent);
    digit := Trunc(num / p);

    if (exponent = -1) and (num > 0.0) then
      Result := Result + ',';

    Result := Result + al[digit];
    num := num - p * digit;
    Dec(exponent);
  end;
end;

procedure TDemoAssistant.com(s: string);
begin
  case s of
    'demo': demo;
    '2ip4': twoIp4;
    'mask': maskIp4;
    'bin': BToI;
    'float': PrintFloat;
    'nsys': numToNS;
    'help': help;
  end;
end;

procedure TDemoAssistant.help;
begin
  writeln('demo, 2ip4, mask, float, bin, nsys, help');
end;

procedure TDemoAssistant.demo;
var
  n, r, r05: double;
  s: string;
begin
  Write('2^');
  readln(n);
  r := 2 ** n;
  r05 := 2 ** n + 0.5;
  writeln('2^', floattostr(n), '       = ', r);
  writeln('2^', floattostr(n), ' + 0.5 = ', r05);

  s := floatToBin(r);
  Insert(' ', s, 13);
  Insert(' ', s, 2);
  writeln(s);

  s := floatToBin(r05);
  Insert(' ', s, 13);
  Insert(' ', s, 2);
  writeln(s);
end;

procedure TDemoAssistant.twoIp4;
var
  s: string;
  ip4_1, ip4_2: TipV4;
  m, rMin, rMax, Broadcast: TipV4;
  i: integer;
  fm: boolean;

  function mmm(a, b: byte): byte;
  var
    i: integer;
  begin
    i := 0;
    while a <> b do
    begin
      a := a div 2;
      b := b div 2;
      Inc(i);
    end;
    Result := 256 - 2 ** i;
  end;

begin
  repeat
    Write('ip4 1:');
    ReadLn(s);
  until TryStrToIpV4(s, ip4_1);

  repeat
    Write('ip4 2:');
    ReadLn(s);
  until TryStrToIpV4(s, ip4_2);

  writeln(ipToBin(ip4_1));
  writeln(ipToBin(ip4_2));

  fm := False;
  for i := low(ip4_1) to High(ip4_1) do
  begin
    if not fm then
    begin
      m[i] := mmm(ip4_1[i], ip4_2[i]);
      if m[i] <> 255 then fm := True;
    end
    else
      m[i] := 0;
  end;
  writeln(u8a('Маска'));
  writeln(ipToStr(m));
  writeln(ipToBin(m));


  for i := low(ip4_1) to High(ip4_1) do
  begin
    rMin[i] := ip4_1[i] and m[i];
    Broadcast[i] := rMin[i] + (255 xor m[i]);
    rMax[i] := Broadcast[i];
  end;
  Dec(rmax[3]);
  writeln;
  writeln(u8a('Начальный адрес сети'));
  writeln(ipToStr(rMin));
  writeln(ipToBin(rMin));
  writeln(u8a('Конечный адрес'));
  writeln(ipToStr(rMax));
  writeln(ipToBin(rMax));
  writeln(u8a('Широковещательный адрес'));
  writeln(ipToStr(Broadcast));
  writeln(ipToBin(Broadcast));
end;

procedure TDemoAssistant.maskIp4;
var
  s: string;
  ip4, m, rMin, rMax, Broadcast: TipV4;
  i: integer;
begin
  repeat
    Write(u8a('ip4   :'));
    ReadLn(s);
  until TryStrToIpV4(s, ip4);
  repeat
    Write(u8a('Маска :'));
    ReadLn(s);
  until TryStrToIpV4(s, m);

  for i := low(ip4) to High(ip4) do
  begin
    rMin[i] := ip4[i] and m[i];
    Broadcast[i] := rMin[i] + (255 xor m[i]);
    rMax[i] := Broadcast[i];
  end;
  Dec(rmax[3]);


  writeln(u8a('ip4'));
  writeln(ipToBin(ip4));
  writeln(u8a('Маска'));
  writeln(ipToBin(m));
  writeln(u8a('Начальный адрес'));
  writeln(ipToStr(rMin));
  writeln(ipToBin(rMin));
  writeln(u8a('Конечный адрес'));
  writeln(ipToStr(rMax));
  writeln(ipToBin(rMax));
  writeln(u8a('Широковещательный адрес'));
  writeln(ipToStr(Broadcast));
  writeln(ipToBin(Broadcast));

end;

function TDemoAssistant.mulstr(s: string; Count: integer): string;
var
  i: integer;
begin
  Result := '';
  if Count <= 0 then Result := ''
  else
  if Count = 1 then Result := s
  else
    for i := 1 to Count do
      Result := Result + s;
end;

function TDemoAssistant.CountChar(const str: string; const ch: string): integer;
var
  p, Count: integer;
begin
  Count := 0;
  p := Pos(ch, str);
  while p > 0 do
  begin
    Inc(Count);
    p := Pos(ch, str, p + 1);
  end;
  Result := Count;
end;

end.

unit HlpHAS160;

{$I ..\Include\HashLib.inc}

interface

uses
{$IFDEF DELPHI2010}
  SysUtils, // to get rid of compiler hint "not inlined" on Delphi 2010.
{$ENDIF DELPHI2010}
  HlpHashLibTypes,
{$IFDEF DELPHI}
  HlpHashBuffer,
  HlpBitConverter,
{$ENDIF DELPHI}
  HlpConverters,
  HlpIHashInfo,
  HlpHashCryptoNotBuildIn;

type
  THAS160 = class sealed(TBlockHash, ICryptoNotBuildIn, ITransformBlock)

  strict private

    Fm_hash: THashLibUInt32Array;
    Fptr_Fm_hash: PCardinal;

{$REGION 'Consts'}

  const

    s_rot: array [0 .. 19] of Int32 = (5, 11, 7, 15, 6, 13, 8, 14, 7, 12, 9, 11,
      8, 15, 6, 12, 9, 14, 5, 13);

    s_tor: array [0 .. 19] of Int32 = (27, 21, 25, 17, 26, 19, 24, 18, 25, 20,
      23, 21, 24, 17, 26, 20, 23, 18, 27, 19);

    s_index: array [0 .. 79] of Int32 = (18, 0, 1, 2, 3, 19, 4, 5, 6, 7, 16, 8,
      9, 10, 11, 17, 12, 13, 14, 15, 18, 3, 6, 9, 12, 19, 15, 2, 5, 8, 16, 11,
      14, 1, 4, 17, 7, 10, 13, 0, 18, 12, 5, 14, 7, 19, 0, 9, 2, 11, 16, 4, 13,
      6, 15, 17, 8, 1, 10, 3, 18, 7, 2, 13, 8, 19, 3, 14, 9, 4, 16, 15, 10, 5,
      0, 17, 11, 6, 1, 12);

{$ENDREGION}
  strict protected
    procedure Finish(); override;
    function GetResult(): THashLibByteArray; override;
    procedure TransformBlock(a_data: PByte; a_data_length: Int32;
      a_index: Int32); override;

  public
    constructor Create();
    procedure Initialize(); override;
  end;

implementation

{ THAS160 }

constructor THAS160.Create;
begin
  Inherited Create(20, 64);
  System.SetLength(Fm_hash, 5);
  Fptr_Fm_hash := PCardinal(Fm_hash);
end;

procedure THAS160.Finish;
var
  pad_index: Int32;
  bits: UInt64;
  pad: THashLibByteArray;
begin
  bits := Fm_processed_bytes * 8;
  if (Fm_buffer.Pos < 56) then
    pad_index := (56 - Fm_buffer.Pos)
  else
    pad_index := (120 - Fm_buffer.Pos);

  System.SetLength(pad, pad_index + 8);

  pad[0] := $80;

  bits := TConverters.le2me_64(bits);

  TConverters.ReadUInt64AsBytesLE(bits, pad, pad_index);

  pad_index := pad_index + 8;

  TransformBytes(pad, 0, pad_index);

end;

function THAS160.GetResult: THashLibByteArray;
begin

  System.SetLength(result, 5 * System.SizeOf(UInt32));

  TConverters.le32_copy(PCardinal(Fm_hash), 0, PByte(result), 0,
    System.Length(result));

end;

procedure THAS160.Initialize;
begin
  Fptr_Fm_hash[0] := $67452301;
  Fptr_Fm_hash[1] := $EFCDAB89;
  Fptr_Fm_hash[2] := $98BADCFE;
  Fptr_Fm_hash[3] := $10325476;
  Fptr_Fm_hash[4] := $C3D2E1F0;

  Inherited Initialize();
end;

procedure THAS160.TransformBlock(a_data: PByte; a_data_length: Int32;
  a_index: Int32);
var
  A, B, C, D, E, T: UInt32;
  r: Int32;
  data: array [0 .. 19] of UInt32;
  ptr_data: PCardinal;
begin
  A := Fptr_Fm_hash[0];
  B := Fptr_Fm_hash[1];
  C := Fptr_Fm_hash[2];
  D := Fptr_Fm_hash[3];
  E := Fptr_Fm_hash[4];

  ptr_data := @(data[0]);

  TConverters.le32_copy(a_data, a_index, ptr_data, 0, 64);

  ptr_data[16] := ptr_data[0] xor ptr_data[1] xor ptr_data[2] xor ptr_data[3];
  ptr_data[17] := ptr_data[4] xor ptr_data[5] xor ptr_data[6] xor ptr_data[7];
  ptr_data[18] := ptr_data[8] xor ptr_data[9] xor ptr_data[10] xor ptr_data[11];
  ptr_data[19] := ptr_data[12] xor ptr_data[13] xor ptr_data[14]
    xor ptr_data[15];

  r := 0;
  while r < 20 do
  begin
    T := ptr_data[s_index[r]] + (A shl s_rot[r] or A shr s_tor[r]) +
      ((B and C) or (not B and D)) + E;
    E := D;
    D := C;
    C := B shl 10 or B shr 22;
    B := A;
    A := T;
    System.Inc(r);
  end;

  ptr_data[16] := ptr_data[3] xor ptr_data[6] xor ptr_data[9] xor ptr_data[12];
  ptr_data[17] := ptr_data[2] xor ptr_data[5] xor ptr_data[8] xor ptr_data[15];
  ptr_data[18] := ptr_data[1] xor ptr_data[4] xor ptr_data[11] xor ptr_data[14];
  ptr_data[19] := ptr_data[0] xor ptr_data[7] xor ptr_data[10] xor ptr_data[13];

  r := 20;
  while r < 40 do
  begin
    T := ptr_data[s_index[r]] + $5A827999 +
      (A shl s_rot[r - 20] or A shr s_tor[r - 20]) + (B xor C xor D) + E;
    E := D;
    D := C;
    C := B shl 17 or B shr 15;
    B := A;
    A := T;
    System.Inc(r);
  end;

  ptr_data[16] := ptr_data[5] xor ptr_data[7] xor ptr_data[12] xor ptr_data[14];
  ptr_data[17] := ptr_data[0] xor ptr_data[2] xor ptr_data[9] xor ptr_data[11];
  ptr_data[18] := ptr_data[4] xor ptr_data[6] xor ptr_data[13] xor ptr_data[15];
  ptr_data[19] := ptr_data[1] xor ptr_data[3] xor ptr_data[8] xor ptr_data[10];

  r := 40;
  while r < 60 do
  begin
    T := ptr_data[s_index[r]] + $6ED9EBA1 +
      (A shl s_rot[r - 40] or A shr s_tor[r - 40]) + (C xor (B or not D)) + E;
    E := D;
    D := C;
    C := B shl 25 or B shr 7;
    B := A;
    A := T;
    System.Inc(r);
  end;

  ptr_data[16] := ptr_data[2] xor ptr_data[7] xor ptr_data[8] xor ptr_data[13];
  ptr_data[17] := ptr_data[3] xor ptr_data[4] xor ptr_data[9] xor ptr_data[14];
  ptr_data[18] := ptr_data[0] xor ptr_data[5] xor ptr_data[10] xor ptr_data[15];
  ptr_data[19] := ptr_data[1] xor ptr_data[6] xor ptr_data[11] xor ptr_data[12];

  r := 60;
  while r < 80 do
  begin
    T := ptr_data[s_index[r]] + $8F1BBCDC +
      (A shl s_rot[r - 60] or A shr s_tor[r - 60]) + (B xor C xor D) + E;
    E := D;
    D := C;
    C := B shl 30 or B shr 2;
    B := A;
    A := T;
    System.Inc(r);
  end;

  Fptr_Fm_hash[0] := Fptr_Fm_hash[0] + A;
  Fptr_Fm_hash[1] := Fptr_Fm_hash[1] + B;
  Fptr_Fm_hash[2] := Fptr_Fm_hash[2] + C;
  Fptr_Fm_hash[3] := Fptr_Fm_hash[3] + D;
  Fptr_Fm_hash[4] := Fptr_Fm_hash[4] + E;

  System.FillChar(data, System.SizeOf(data), 0);

end;

end.
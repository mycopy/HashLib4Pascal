unit HlpRIPEMD256;

{$I ..\Include\HashLib.inc}

interface

uses
{$IFDEF DELPHI2010}
  SysUtils, // to get rid of compiler hint "not inlined" on Delphi 2010.
{$ENDIF DELPHI2010}
  HlpMDBase,
  HlpBits,
{$IFDEF DELPHI}
  HlpBitConverter,
{$ENDIF DELPHI}
  HlpConverters,
  HlpIHashInfo;

type
  TRIPEMD256 = class sealed(TMDBase, ITransformBlock)

  strict protected
    procedure TransformBlock(a_data: PByte; a_data_length: Int32;
      a_index: Int32); override;

  public
    constructor Create();
    procedure Initialize(); override;

  end;

implementation

{ TRIPEMD256 }

constructor TRIPEMD256.Create;
begin
  Inherited Create(8, 32);
end;

procedure TRIPEMD256.Initialize;
begin
  Fptr_Fm_state[4] := $76543210;
  Fptr_Fm_state[5] := $FEDCBA98;
  Fptr_Fm_state[6] := $89ABCDEF;
  Fptr_Fm_state[7] := $01234567;

  Inherited Initialize();

end;

procedure TRIPEMD256.TransformBlock(a_data: PByte; a_data_length: Int32;
  a_index: Int32);
var
  a, b, c, d, aa, bb, cc, dd: UInt32;
  data: array [0 .. 15] of UInt32;
  ptr_data: PCardinal;
begin

  ptr_data := @(data[0]);
  TConverters.le32_copy(a_data, a_index, ptr_data, 0, 64);

  a := Fptr_Fm_state[0];
  b := Fptr_Fm_state[1];
  c := Fptr_Fm_state[2];
  d := Fptr_Fm_state[3];
  aa := Fptr_Fm_state[4];
  bb := Fptr_Fm_state[5];
  cc := Fptr_Fm_state[6];
  dd := Fptr_Fm_state[7];

  a := a + (ptr_data[0] + (b xor c xor d));
  a := TBits.RotateLeft32(a, 11);
  d := d + (ptr_data[1] + (a xor b xor c));
  d := TBits.RotateLeft32(d, 14);
  c := c + (ptr_data[2] + (d xor a xor b));
  c := TBits.RotateLeft32(c, 15);
  b := b + (ptr_data[3] + (c xor d xor a));
  b := TBits.RotateLeft32(b, 12);
  a := a + (ptr_data[4] + (b xor c xor d));
  a := TBits.RotateLeft32(a, 5);
  d := d + (ptr_data[5] + (a xor b xor c));
  d := TBits.RotateLeft32(d, 8);
  c := c + (ptr_data[6] + (d xor a xor b));
  c := TBits.RotateLeft32(c, 7);
  b := b + (ptr_data[7] + (c xor d xor a));
  b := TBits.RotateLeft32(b, 9);
  a := a + (ptr_data[8] + (b xor c xor d));
  a := TBits.RotateLeft32(a, 11);
  d := d + (ptr_data[9] + (a xor b xor c));
  d := TBits.RotateLeft32(d, 13);
  c := c + (ptr_data[10] + (d xor a xor b));
  c := TBits.RotateLeft32(c, 14);
  b := b + (ptr_data[11] + (c xor d xor a));
  b := TBits.RotateLeft32(b, 15);
  a := a + (ptr_data[12] + (b xor c xor d));
  a := TBits.RotateLeft32(a, 6);
  d := d + (ptr_data[13] + (a xor b xor c));
  d := TBits.RotateLeft32(d, 7);
  c := c + (ptr_data[14] + (d xor a xor b));
  c := TBits.RotateLeft32(c, 9);
  b := b + (ptr_data[15] + (c xor d xor a));
  b := TBits.RotateLeft32(b, 8);

  aa := aa + (ptr_data[5] + C1 + ((bb and dd) or (cc and not dd)));
  aa := TBits.RotateLeft32(aa, 8);
  dd := dd + (ptr_data[14] + C1 + ((aa and cc) or (bb and not cc)));
  dd := TBits.RotateLeft32(dd, 9);
  cc := cc + (ptr_data[7] + C1 + ((dd and bb) or (aa and not bb)));
  cc := TBits.RotateLeft32(cc, 9);
  bb := bb + (ptr_data[0] + C1 + ((cc and aa) or (dd and not aa)));
  bb := TBits.RotateLeft32(bb, 11);
  aa := aa + (ptr_data[9] + C1 + ((bb and dd) or (cc and not dd)));
  aa := TBits.RotateLeft32(aa, 13);
  dd := dd + (ptr_data[2] + C1 + ((aa and cc) or (bb and not cc)));
  dd := TBits.RotateLeft32(dd, 15);
  cc := cc + (ptr_data[11] + C1 + ((dd and bb) or (aa and not bb)));
  cc := TBits.RotateLeft32(cc, 15);
  bb := bb + (ptr_data[4] + C1 + ((cc and aa) or (dd and not aa)));
  bb := TBits.RotateLeft32(bb, 5);
  aa := aa + (ptr_data[13] + C1 + ((bb and dd) or (cc and not dd)));
  aa := TBits.RotateLeft32(aa, 7);
  dd := dd + (ptr_data[6] + C1 + ((aa and cc) or (bb and not cc)));
  dd := TBits.RotateLeft32(dd, 7);
  cc := cc + (ptr_data[15] + C1 + ((dd and bb) or (aa and not bb)));
  cc := TBits.RotateLeft32(cc, 8);
  bb := bb + (ptr_data[8] + C1 + ((cc and aa) or (dd and not aa)));
  bb := TBits.RotateLeft32(bb, 11);
  aa := aa + (ptr_data[1] + C1 + ((bb and dd) or (cc and not dd)));
  aa := TBits.RotateLeft32(aa, 14);
  dd := dd + (ptr_data[10] + C1 + ((aa and cc) or (bb and not cc)));
  dd := TBits.RotateLeft32(dd, 14);
  cc := cc + (ptr_data[3] + C1 + ((dd and bb) or (aa and not bb)));
  cc := TBits.RotateLeft32(cc, 12);
  bb := bb + (ptr_data[12] + C1 + ((cc and aa) or (dd and not aa)));
  bb := TBits.RotateLeft32(bb, 6);

  aa := aa + (ptr_data[7] + C2 + ((b and c) or (not b and d)));
  aa := TBits.RotateLeft32(aa, 7);
  d := d + (ptr_data[4] + C2 + ((aa and b) or (not aa and c)));
  d := TBits.RotateLeft32(d, 6);
  c := c + (ptr_data[13] + C2 + ((d and aa) or (not d and b)));
  c := TBits.RotateLeft32(c, 8);
  b := b + (ptr_data[1] + C2 + ((c and d) or (not c and aa)));
  b := TBits.RotateLeft32(b, 13);
  aa := aa + (ptr_data[10] + C2 + ((b and c) or (not b and d)));
  aa := TBits.RotateLeft32(aa, 11);
  d := d + (ptr_data[6] + C2 + ((aa and b) or (not aa and c)));
  d := TBits.RotateLeft32(d, 9);
  c := c + (ptr_data[15] + C2 + ((d and aa) or (not d and b)));
  c := TBits.RotateLeft32(c, 7);
  b := b + (ptr_data[3] + C2 + ((c and d) or (not c and aa)));
  b := TBits.RotateLeft32(b, 15);
  aa := aa + (ptr_data[12] + C2 + ((b and c) or (not b and d)));
  aa := TBits.RotateLeft32(aa, 7);
  d := d + (ptr_data[0] + C2 + ((aa and b) or (not aa and c)));
  d := TBits.RotateLeft32(d, 12);
  c := c + (ptr_data[9] + C2 + ((d and aa) or (not d and b)));
  c := TBits.RotateLeft32(c, 15);
  b := b + (ptr_data[5] + C2 + ((c and d) or (not c and aa)));
  b := TBits.RotateLeft32(b, 9);
  aa := aa + (ptr_data[2] + C2 + ((b and c) or (not b and d)));
  aa := TBits.RotateLeft32(aa, 11);
  d := d + (ptr_data[14] + C2 + ((aa and b) or (not aa and c)));
  d := TBits.RotateLeft32(d, 7);
  c := c + (ptr_data[11] + C2 + ((d and aa) or (not d and b)));
  c := TBits.RotateLeft32(c, 13);
  b := b + (ptr_data[8] + C2 + ((c and d) or (not c and aa)));
  b := TBits.RotateLeft32(b, 12);

  a := a + (ptr_data[6] + C3 + ((bb or not cc) xor dd));
  a := TBits.RotateLeft32(a, 9);
  dd := dd + (ptr_data[11] + C3 + ((a or not bb) xor cc));
  dd := TBits.RotateLeft32(dd, 13);
  cc := cc + (ptr_data[3] + C3 + ((dd or not a) xor bb));
  cc := TBits.RotateLeft32(cc, 15);
  bb := bb + (ptr_data[7] + C3 + ((cc or not dd) xor a));
  bb := TBits.RotateLeft32(bb, 7);
  a := a + (ptr_data[0] + C3 + ((bb or not cc) xor dd));
  a := TBits.RotateLeft32(a, 12);
  dd := dd + (ptr_data[13] + C3 + ((a or not bb) xor cc));
  dd := TBits.RotateLeft32(dd, 8);
  cc := cc + (ptr_data[5] + C3 + ((dd or not a) xor bb));
  cc := TBits.RotateLeft32(cc, 9);
  bb := bb + (ptr_data[10] + C3 + ((cc or not dd) xor a));
  bb := TBits.RotateLeft32(bb, 11);
  a := a + (ptr_data[14] + C3 + ((bb or not cc) xor dd));
  a := TBits.RotateLeft32(a, 7);
  dd := dd + (ptr_data[15] + C3 + ((a or not bb) xor cc));
  dd := TBits.RotateLeft32(dd, 7);
  cc := cc + (ptr_data[8] + C3 + ((dd or not a) xor bb));
  cc := TBits.RotateLeft32(cc, 12);
  bb := bb + (ptr_data[12] + C3 + ((cc or not dd) xor a));
  bb := TBits.RotateLeft32(bb, 7);
  a := a + (ptr_data[4] + C3 + ((bb or not cc) xor dd));
  a := TBits.RotateLeft32(a, 6);
  dd := dd + (ptr_data[9] + C3 + ((a or not bb) xor cc));
  dd := TBits.RotateLeft32(dd, 15);
  cc := cc + (ptr_data[1] + C3 + ((dd or not a) xor bb));
  cc := TBits.RotateLeft32(cc, 13);
  bb := bb + (ptr_data[2] + C3 + ((cc or not dd) xor a));
  bb := TBits.RotateLeft32(bb, 11);

  aa := aa + (ptr_data[3] + C4 + ((bb or not c) xor d));
  aa := TBits.RotateLeft32(aa, 11);
  d := d + (ptr_data[10] + C4 + ((aa or not bb) xor c));
  d := TBits.RotateLeft32(d, 13);
  c := c + (ptr_data[14] + C4 + ((d or not aa) xor bb));
  c := TBits.RotateLeft32(c, 6);
  bb := bb + (ptr_data[4] + C4 + ((c or not d) xor aa));
  bb := TBits.RotateLeft32(bb, 7);
  aa := aa + (ptr_data[9] + C4 + ((bb or not c) xor d));
  aa := TBits.RotateLeft32(aa, 14);
  d := d + (ptr_data[15] + C4 + ((aa or not bb) xor c));
  d := TBits.RotateLeft32(d, 9);
  c := c + (ptr_data[8] + C4 + ((d or not aa) xor bb));
  c := TBits.RotateLeft32(c, 13);
  bb := bb + (ptr_data[1] + C4 + ((c or not d) xor aa));
  bb := TBits.RotateLeft32(bb, 15);
  aa := aa + (ptr_data[2] + C4 + ((bb or not c) xor d));
  aa := TBits.RotateLeft32(aa, 14);
  d := d + (ptr_data[7] + C4 + ((aa or not bb) xor c));
  d := TBits.RotateLeft32(d, 8);
  c := c + (ptr_data[0] + C4 + ((d or not aa) xor bb));
  c := TBits.RotateLeft32(c, 13);
  bb := bb + (ptr_data[6] + C4 + ((c or not d) xor aa));
  bb := TBits.RotateLeft32(bb, 6);
  aa := aa + (ptr_data[13] + C4 + ((bb or not c) xor d));
  aa := TBits.RotateLeft32(aa, 5);
  d := d + (ptr_data[11] + C4 + ((aa or not bb) xor c));
  d := TBits.RotateLeft32(d, 12);
  c := c + (ptr_data[5] + C4 + ((d or not aa) xor bb));
  c := TBits.RotateLeft32(c, 7);
  bb := bb + (ptr_data[12] + C4 + ((c or not d) xor aa));
  bb := TBits.RotateLeft32(bb, 5);

  a := a + (ptr_data[15] + C5 + ((b and cc) or (not b and dd)));
  a := TBits.RotateLeft32(a, 9);
  dd := dd + (ptr_data[5] + C5 + ((a and b) or (not a and cc)));
  dd := TBits.RotateLeft32(dd, 7);
  cc := cc + (ptr_data[1] + C5 + ((dd and a) or (not dd and b)));
  cc := TBits.RotateLeft32(cc, 15);
  b := b + (ptr_data[3] + C5 + ((cc and dd) or (not cc and a)));
  b := TBits.RotateLeft32(b, 11);
  a := a + (ptr_data[7] + C5 + ((b and cc) or (not b and dd)));
  a := TBits.RotateLeft32(a, 8);
  dd := dd + (ptr_data[14] + C5 + ((a and b) or (not a and cc)));
  dd := TBits.RotateLeft32(dd, 6);
  cc := cc + (ptr_data[6] + C5 + ((dd and a) or (not dd and b)));
  cc := TBits.RotateLeft32(cc, 6);
  b := b + (ptr_data[9] + C5 + ((cc and dd) or (not cc and a)));
  b := TBits.RotateLeft32(b, 14);
  a := a + (ptr_data[11] + C5 + ((b and cc) or (not b and dd)));
  a := TBits.RotateLeft32(a, 12);
  dd := dd + (ptr_data[8] + C5 + ((a and b) or (not a and cc)));
  dd := TBits.RotateLeft32(dd, 13);
  cc := cc + (ptr_data[12] + C5 + ((dd and a) or (not dd and b)));
  cc := TBits.RotateLeft32(cc, 5);
  b := b + (ptr_data[2] + C5 + ((cc and dd) or (not cc and a)));
  b := TBits.RotateLeft32(b, 14);
  a := a + (ptr_data[10] + C5 + ((b and cc) or (not b and dd)));
  a := TBits.RotateLeft32(a, 13);
  dd := dd + (ptr_data[0] + C5 + ((a and b) or (not a and cc)));
  dd := TBits.RotateLeft32(dd, 13);
  cc := cc + (ptr_data[4] + C5 + ((dd and a) or (not dd and b)));
  cc := TBits.RotateLeft32(cc, 7);
  b := b + (ptr_data[13] + C5 + ((cc and dd) or (not cc and a)));
  b := TBits.RotateLeft32(b, 5);

  aa := aa + (ptr_data[1] + C6 + ((bb and d) or (cc and not d)));
  aa := TBits.RotateLeft32(aa, 11);
  d := d + (ptr_data[9] + C6 + ((aa and cc) or (bb and not cc)));
  d := TBits.RotateLeft32(d, 12);
  cc := cc + (ptr_data[11] + C6 + ((d and bb) or (aa and not bb)));
  cc := TBits.RotateLeft32(cc, 14);
  bb := bb + (ptr_data[10] + C6 + ((cc and aa) or (d and not aa)));
  bb := TBits.RotateLeft32(bb, 15);
  aa := aa + (ptr_data[0] + C6 + ((bb and d) or (cc and not d)));
  aa := TBits.RotateLeft32(aa, 14);
  d := d + (ptr_data[8] + C6 + ((aa and cc) or (bb and not cc)));
  d := TBits.RotateLeft32(d, 15);
  cc := cc + (ptr_data[12] + C6 + ((d and bb) or (aa and not bb)));
  cc := TBits.RotateLeft32(cc, 9);
  bb := bb + (ptr_data[4] + C6 + ((cc and aa) or (d and not aa)));
  bb := TBits.RotateLeft32(bb, 8);
  aa := aa + (ptr_data[13] + C6 + ((bb and d) or (cc and not d)));
  aa := TBits.RotateLeft32(aa, 9);
  d := d + (ptr_data[3] + C6 + ((aa and cc) or (bb and not cc)));
  d := TBits.RotateLeft32(d, 14);
  cc := cc + (ptr_data[7] + C6 + ((d and bb) or (aa and not bb)));
  cc := TBits.RotateLeft32(cc, 5);
  bb := bb + (ptr_data[15] + C6 + ((cc and aa) or (d and not aa)));
  bb := TBits.RotateLeft32(bb, 6);
  aa := aa + (ptr_data[14] + C6 + ((bb and d) or (cc and not d)));
  aa := TBits.RotateLeft32(aa, 8);
  d := d + (ptr_data[5] + C6 + ((aa and cc) or (bb and not cc)));
  d := TBits.RotateLeft32(d, 6);
  cc := cc + (ptr_data[6] + C6 + ((d and bb) or (aa and not bb)));
  cc := TBits.RotateLeft32(cc, 5);
  bb := bb + (ptr_data[2] + C6 + ((cc and aa) or (d and not aa)));
  bb := TBits.RotateLeft32(bb, 12);

  a := a + (ptr_data[8] + (b xor c xor dd));
  a := TBits.RotateLeft32(a, 15);
  dd := dd + (ptr_data[6] + (a xor b xor c));
  dd := TBits.RotateLeft32(dd, 5);
  c := c + (ptr_data[4] + (dd xor a xor b));
  c := TBits.RotateLeft32(c, 8);
  b := b + (ptr_data[1] + (c xor dd xor a));
  b := TBits.RotateLeft32(b, 11);
  a := a + (ptr_data[3] + (b xor c xor dd));
  a := TBits.RotateLeft32(a, 14);
  dd := dd + (ptr_data[11] + (a xor b xor c));
  dd := TBits.RotateLeft32(dd, 14);
  c := c + (ptr_data[15] + (dd xor a xor b));
  c := TBits.RotateLeft32(c, 6);
  b := b + (ptr_data[0] + (c xor dd xor a));
  b := TBits.RotateLeft32(b, 14);
  a := a + (ptr_data[5] + (b xor c xor dd));
  a := TBits.RotateLeft32(a, 6);
  dd := dd + (ptr_data[12] + (a xor b xor c));
  dd := TBits.RotateLeft32(dd, 9);
  c := c + (ptr_data[2] + (dd xor a xor b));
  c := TBits.RotateLeft32(c, 12);
  b := b + (ptr_data[13] + (c xor dd xor a));
  b := TBits.RotateLeft32(b, 9);
  a := a + (ptr_data[9] + (b xor c xor dd));
  a := TBits.RotateLeft32(a, 12);
  dd := dd + (ptr_data[7] + (a xor b xor c));
  dd := TBits.RotateLeft32(dd, 5);
  c := c + (ptr_data[10] + (dd xor a xor b));
  c := TBits.RotateLeft32(c, 15);
  b := b + (ptr_data[14] + (c xor dd xor a));
  b := TBits.RotateLeft32(b, 8);

  Fptr_Fm_state[0] := Fptr_Fm_state[0] + aa;
  Fptr_Fm_state[1] := Fptr_Fm_state[1] + bb;
  Fptr_Fm_state[2] := Fptr_Fm_state[2] + cc;
  Fptr_Fm_state[3] := Fptr_Fm_state[3] + dd;
  Fptr_Fm_state[4] := Fptr_Fm_state[4] + a;
  Fptr_Fm_state[5] := Fptr_Fm_state[5] + b;
  Fptr_Fm_state[6] := Fptr_Fm_state[6] + c;
  Fptr_Fm_state[7] := Fptr_Fm_state[7] + d;

  System.FillChar(data, System.SizeOf(data), 0);

end;

end.
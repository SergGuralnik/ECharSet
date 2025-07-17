Library ECharSet;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters.

  Important note about VCL usage: when this DLL will be implicitly
  loaded and this DLL uses TWicImage / TImageCollection created in
  any unit initialization section, then Vcl.WicImageInit must be
  included into your library's USES clause. }

Uses
  System.SysUtils,
  System.Classes,
  CD.DetectionResult,
  CharsetEnigma.Core;

{$R *.res}

Function GetFileCharSet(AFileName : PChar; Var ACodePage : Integer; Var ABOM : Boolean; Var AResult : Byte) : Boolean; StdCall;

Var
  LR : IDetectionResult;
  FS : TFileStream;
  AB : Array[0..2] Of Byte;

Begin
  Result     := False;
  AResult    := 0;
  If (AFileName = '') Or Not FileExists(AFileName) Then
  Begin
    AResult  := 1;
    Exit
  End;
  Try
    FS       := TFileStream.Create(AFileName, fmOpenRead)
  Except
    AResult  := 2;
    Exit
  End;
  With FS Do
  Begin
    Position := 0;
    Read(AB, 3);
    Position := 0
  End;
  Try
    LR       := TCharSetEnigma.DetectFromStream(FS);
  Finally
    FreeAndNil(FS);
  End;
  If Not Assigned(LR.Detected) Then
  Begin
    AResult  := 3;
    Exit
  End;
  ACodePage  := LR.Detected.Encoding.CodePage;
  ABOM       := (ACodePage = 65001) And (AB[0] = $EF) And (AB[1] = $BB) And (AB[2] = $BF);
  Result     := True
End;

Exports GetFileCharSet;

Begin
End.

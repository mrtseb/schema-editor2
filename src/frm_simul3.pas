unit frm_simul3;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, jvcomponent, jvsyscomp,sim_utils, ExtCtrls, tabassoc,
  Menus, ImgList, Buttons, schema_utils, ShellAPI;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    MainMenu1: TMainMenu;
    Fichier1: TMenuItem;
    Edition1: TMenuItem;
    Simuler1: TMenuItem;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    ImageList1: TImageList;
    Quitter1: TMenuItem;
    Stopper1: TMenuItem;
    Memo3: TMemo;
    box_check: TPanel;
    memo2: TMemo;
    box_check2: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Quitter1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Stopper1Click(Sender: TObject);
    procedure Simuler1Click(Sender: TObject);
    procedure set_letter(Sender: TObject);
    procedure simul_letter(Sender: TObject);
     private
    { DÃ©clarations privÃ©es }


  public
    { DÃ©clarations publiques }

    //destinatio:string;
    dir:string;
    etape, choix:integer;
    //nb_noeuds,max_links:integer;
    secondes: single;
    dico:TableauAssociatif;
    deb,fin:string;
    isSimulate, isPlacing,isBinding, spicing:boolean;
    schema:Tschema;
    procedure relie(a,b:string);
    procedure analyse;
    procedure gere_sim(s:string);
    Procedure load_bmp(p:pentry);
    procedure Process1Read(Sender: TObject; const S: string);
    procedure Process1Terminate(Sender: TObject; ExitCode: Cardinal);

end;

var
  Form1: TForm1;
  letter: shortstring;

implementation
uses
  JclSysInfo, JclStrings, JvDSADialogs;
{$IFnDEF FPC}
  {$IFnDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

Procedure Tform1.load_bmp(p:pentry);
var bmp:Tbitmap;
begin
   bmp:=Tbitmap.create;
   bmp.Width:=33;
   bmp.Height:=33;
   bmp.Canvas.Brush.Color:=form1.Color;
   bmp.Canvas.FillRect(Rect(0,0,33,33));
   form1.Canvas.Draw(p^.X,p^.Y,bmp);
   bmp.loadfromFile(extractfilepath(Application.exename)+'img\'+p^.device+'.bmp');
   bmp.Transparent :=true;
   bmp.TransparentColor:=clFuchsia;
   bmp.canvas.pen.Color:=clblack;
   bmp.Canvas.TextOut(0,0,p^.letter);

   form1.Canvas.Draw(p^.X,p^.Y,bmp);
   bmp.free;
end;


Procedure Tform1.gere_sim(s:string);
var p:pentry;

begin

        p:=schema.l.Items[strtoint(s)];
        if p^.device ='P' then exit;
        if p^.device ='N' then exit;
        if p^.device ='LMP0' then exit;
        if p^.device ='NO0' then begin
            p^.device:='NO1';
        end else
        if p^.device ='NO1' then begin
            p^.device:='NO0';
        end else
        if p^.device ='NF0' then begin
            p^.device:='NF1';
        end else
        if p^.device ='NF1' then begin
            p^.device:='NF0';
        end;

        self.load_bmp(p);
        
end;

procedure Tform1.simul_letter(Sender: TObject);
var l:Tlist;
i:integer;
p: pentry;
begin
 l:=Tlist.create;
 l:=schema.trouve_by_letter((sender as Tcheckbox).caption);
 for i := 0 to l.Count-1 do begin
   p:=l[i];
   gere_sim(inttostr(p^.num));
 end;
 self.Simuler1Click(self);
 l.Free;
end;

procedure Tform1.set_letter(Sender: TObject);
begin
 letter:=(sender as tradiobutton).Caption;
 //self.caption:=letter;
end;
procedure Tform1.analyse;
var i:integer;
    v1,v2:double;
    pp:pentry;
    bmp:Tbitmap;
begin

bmp:=Tbitmap.create;

for i:=0 to self.schema.l.Count-1 do begin
    pp:=self.schema.l[i];
    if pos('LMP',pp^.device) > 0 then begin
      if dico['V('+inttostr(pp^.pin1)+')']='' then dico['V('+inttostr(pp^.pin1)+')']:='0,0';
      if dico['V('+inttostr(pp^.pin2)+')']='' then dico['V('+inttostr(pp^.pin2)+')']:='0,0';
      v1:= strtofloat(dico['V('+inttostr(pp^.pin1)+')']);
      if pp^.pin2=0 then v2:= 0.0 else v2:=strtofloat(dico['V('+inttostr(pp^.pin2)+')']);
      //memo2.lines.add(floattostr(v1));
      //memo2.lines.add(floattostr(v2));
      if pp^.device ='LMP0' then if v1-v2>5 then begin
            pp^.device:='LMP1';
            bmp.Width:=33;
            bmp.Height:=33;
            bmp.Canvas.Brush.Color:=form1.Color;
            bmp.Canvas.FillRect(Rect(0,0,33,33));
            form1.Canvas.Draw(pp^.X,pp^.Y,bmp);
            bmp.loadfromFile(extractfilepath(Application.exename)+'img\LMP1.bmp');
            bmp.Transparent :=true;
            bmp.TransparentColor:=clFuchsia;
            form1.Canvas.Draw(pp^.X,pp^.Y,bmp);
            continue;
        end;
        if pp^.device ='LMP1' then if v1-v2< 1 then begin
            pp^.device:='LMP0';
            bmp.Width:=33;
            bmp.Height:=33;
            bmp.Canvas.Brush.Color:=form1.Color;
            bmp.Canvas.FillRect(Rect(0,0,33,33));
            form1.Canvas.Draw(pp^.X,pp^.Y,bmp);
            bmp.loadfromFile(extractfilepath(Application.exename)+'img\LMP0.bmp');
            bmp.Transparent :=true;
            bmp.TransparentColor:=clFuchsia;
            form1.Canvas.Draw(pp^.X,pp^.Y,bmp);
            continue;
        end;

    end;
end;

bmp.free;

end;

procedure Tform1.relie(a,b:string);
var id_deb,id_fin:integer;

    t:Tstringlist;
    x1,y1,x2,y2, z1:integer;
    lien:Tlink;
    s:string;
    p:Pentry;

begin


  if a='' then exit;
  if a='-' then exit;
  if b='' then exit;
  if b='-' then exit;


  id_deb:=strtoint(a);
  id_fin:=strtoint(b);

  x1:=schema.trouve_by_id(id_deb).X;
  y1:=schema.trouve_by_id(id_deb).Y+33 div 2;
  x2:=schema.trouve_by_id(id_fin).X;
  y2:=schema.trouve_by_id(id_fin).Y+33 div 2;

  if x1>x2 then begin
      z1:=x2;  x2:=x1;  x1:=z1;
      z1:=y2;  y2:=y1;  y1:=z1;
  end;


  schema.add_link(id_deb,id_fin);

  //memo2.Clear;
  //memo2.Lines:=schema.show_entries;

  form1.canvas.moveto(x1+33,y1);
  form1.canvas.Pen.Color:=clBlack;

  if schema.trouve_by_id(id_deb).device='P' then form1.canvas.Pen.Color:=clRed;
  if schema.trouve_by_id(id_deb).device='N' then form1.canvas.Pen.Color:=clBlue;
  if schema.trouve_by_id(id_fin).device='P' then form1.canvas.Pen.Color:=clRed;
  if schema.trouve_by_id(id_fin).device='N' then form1.canvas.Pen.Color:=clBlue;

  form1.canvas.lineto(x1+33,y2);
  form1.canvas.lineto(x2,y2);



end;

resourcestring
  sProcessTerminated = 'Process "%s" terminated, ExitCode: %.8x';

procedure ExecuteAndWait(const Commande: string);
var
  tmpStartupInfo: TStartupInfo;
  tmpProcessInformation: TProcessInformation;
  tmpProgram: String;
begin
  tmpProgram := trim(Commande);
  FillChar(tmpStartupInfo, SizeOf(tmpStartupInfo), 0);
  with tmpStartupInfo do
  begin
    cb := SizeOf(TStartupInfo);
    wShowWindow := SW_HIDE;
  end;

  if CreateProcess(nil, pchar(tmpProgram), nil, nil, true, CREATE_NO_WINDOW,
    nil, nil, tmpStartupInfo, tmpProcessInformation) then
  begin
    // loop every 10 ms
    while WaitForSingleObject(tmpProcessInformation.hProcess, 10) > 0 do
    begin
      Application.ProcessMessages;
    end;
    CloseHandle(tmpProcessInformation.hProcess);
    CloseHandle(tmpProcessInformation.hThread);
  end
  else
  begin
    RaiseLastOSError;
  end;
end;

procedure Split(Delimiter: Char; Str: string; ListOfStrings: TStrings) ;
begin
   ListOfStrings.Clear;
   ListOfStrings.Delimiter     := Delimiter;
   ListOfStrings.DelimitedText := Str;
end;

procedure DoSplit(sep: char; chaine: string; outString:TstringList);
begin
     Split(sep, chaine, OutString);
end;

procedure Tform1.Process1Terminate(Sender: TObject; ExitCode: Cardinal);
begin
end;

procedure Tform1.Process1Read(Sender: TObject; const S: string);
begin
  // $0C is the Form Feed char.
  if S = #$C then
    //memo1.Clear
  else
    //memo1.Lines.Add(S)

end;

procedure TForm1.FormCreate(Sender: TObject);
var i:integer;
    bmp:Tbitmap;
    ck:Tradiobutton;
    ck2:Tcheckbox;
begin

for i:=1 to 26 do begin
  ck:= Tradiobutton.Create(self.box_check);
  ck.Name:='int'+chr(64+i);
  ck.Parent := self.box_check;
  ck.Visible:=true;
  ck.Caption:=chr(64+i);
  ck.Tag := i;
  ck.Width:=27;
  ck.left:=250+(i-1)*30;
  if i=1 then
  begin ck.Checked:=true;
  set_letter(ck);
  end;
  ck.OnClick:=set_letter;

  ck2:= Tcheckbox.Create(self.box_check2);
  ck2.Name:='int'+chr(64+i);
  ck2.Parent := self.box_check2;
  ck2.Visible:=true;
  ck2.Caption:=chr(64+i);
  ck2.Tag := i;
  ck2.Width:=27;
  ck2.left:=250+(i-1)*30;
  ck2.OnClick:=simul_letter;


end;
self.box_check.Height:=self.box_check.Controls[0].Height;
self.box_check2.Height:=self.box_check2.Controls[0].Height;
self.box_check2.Hide;

isSimulate:=false;
//memo3.lines.Clear;
//memo3.lines.add('Circuit elec.');
schema:=Tschema.create;
dico:=TableauAssociatif.Create;
dir:=ExtractFilePath(Application.ExeName);
//self.Memo3.Lines.LoadFromFile(dir+'circuits\simple.cir');

dir:=ExtractFilePath(Application.ExeName);

//memo2.clear;
  Bmp := TBitmap.Create;
  try
    for i:=1 to imagelist1.Count do begin
      bmp.Transparent:=true;
      bmp.TransparentColor:=clFuchsia;
      bmp.Canvas.Brush.color:=clFuchsia;
      bmp.Canvas.pen.color:=clBlack;
      bmp.Canvas.Rectangle(0,0,32,32);
      ImageList1.GetBitmap(i-1, Bmp);
      (Findcomponent('Speedbutton'+IntToStr(i)) as TSpeedButton).Glyph.Assign(bmp);

    end;

  finally
    Bmp.Free;
  end;


end;




procedure TForm1.Timer1Timer(Sender: TObject);
begin
secondes:=secondes+(self.Timer1.Interval/1000);
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
   var
   Bmp: TBitmap;
   e:Tentry;
   p:pEntry;
   s:string;

   begin
  try
    Bmp:=Tbitmap.create;

     X := (X div 50) * 50;
     Y := (Y div 50) * 50;

    //if isSimulate then begin
    //    if spicing then exit;
    //    s:=schema.trouve_composant_node(X,Y);
    //    if s='-' then exit;
    //    gere_sim(s);
    //    exit;
    //end;

    if isPlacing then begin
        //if (choix<>7) then if (X < 100) then exit;
        if schema.dejala(X,Y)then exit;
        ImageList1.GetBitmap(choix, Bmp);
        bmp.Transparent:=true;
        bmp.TransparentColor:=clFuchsia;
        bmp.Canvas.Brush.color:=clFuchsia;
        bmp.Canvas.pen.color:=clFuchsia;
        bmp.Canvas.Rectangle(0,0,33,33);
        ImageList1.GetBitmap(choix, Bmp);
        if choix=0 then
           begin
             if not schema.alim then begin
                form1.Canvas.Draw(X,Y,bmp);
             end;
           end
        else
        begin
        if (choix=2) then bmp.Canvas.TextOut(0,0,'/'+letter);
        if (choix=3) then bmp.Canvas.TextOut(0,0,letter);

        if (choix>1) and (choix<4) then ;
        form1.Canvas.Draw(X,Y,bmp);
        end;
        schema.add_entry(X,Y,choix,letter);
        memo2.Lines := schema.show_entries;
        exit;
  end;
  //binding
  self.isBinding:=true;
  deb:=schema.trouve_composant_node(X,Y);

  finally begin
    bmp.free;
    isPlacing:=false;
  end;
    end;
  end;


procedure TForm1.SpeedButton1Click(Sender: TObject);

begin
      isPlacing:=true;
      choix:=(sender as TspeedButton).tag;
end;


procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   X := (X div 50) * 50;
   Y := (Y div 50) * 50;

   if isSimulate then begin
       deb:='-';
       fin:='-';
       exit;
    end;

  if isplacing then else isBinding:=false;


  if deb='-' then exit;
  if deb='' then exit;

  fin:=schema.trouve_composant_node(X,Y);
  if deb=fin then exit;
  if fin='-' then exit;

  self.relie(deb,fin);
  deb:='-';
  fin:='-'
end;

procedure TForm1.Quitter1Click(Sender: TObject);
begin
self.close;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
schema.destroy;
end;

procedure TForm1.Stopper1Click(Sender: TObject);
begin
isSimulate:=false;
timer1.Enabled:=false;
self.box_check2.Visible:=false;
self.box_check.Visible:=true;
end;

procedure TForm1.Simuler1Click(Sender: TObject);

var s, ss:string;
    t:Tstringlist;

begin
self.box_check2.Visible:=true;
self.box_check.Hide;
spicing:=true;
isSimulate:=true;
memo3.lines:=schema.gen_netlist;
timer1.Enabled:=true;

memo3.lines.SaveToFile(dir+'circuits\temp.cir');
if fileexists(dir+'circuits\temp.raw') then deletefile(dir+'circuits\temp.raw');
secondes:=0;
shellexecute(Handle,'Open',pAnsiChar(dir +'Opus\opus.exe'),pansichar(' -b -r temp.raw temp.cir'),pansichar(dir+'\circuits'),SW_HIDE);
s:= dir+'circuits\temp.raw';
while not fileexists(s) do;
//memo1.lines.Add('Analyse des résultats ...');
raw_readtxt(s,dir,dico);
timer1.Enabled:=false;
//memo1.lines.Add('Analyse terminée en '+floattostr(secondes)+'  sec.');
analyse;
spicing:=false;






//memo1.Clear;
//memo1.lines.add('Processus lancé');
end;

end.

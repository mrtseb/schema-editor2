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
    Enregistrer1: TMenuItem;
    Nouveau1: TMenuItem;
    Ouvrir1: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;                                                                                                               
    SpeedButton6: TSpeedButton;
    placer: TRadioButton;
    RadioButton1: TRadioButton;
    Memo1: TMemo;
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
    procedure Enregistrer1Click(Sender: TObject);
    procedure Nouveau1Click(Sender: TObject);
    procedure Ouvrir1Click(Sender: TObject);
    procedure placerClick(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
     private
    { Déclarations privées }


  public
    { Déclarations publiques }

    //destinatio:string;
    dir:string;
    etape, choix:integer;
    //nb_noeuds,max_links:integer;
    secondes: single;
    dico:TableauAssociatif;
    deb,fin:string;
    isSimulate, isPlacing,isBinding, spicing:boolean;
    schema:Tschema;
    procedure relie(a,b:string;mode:boolean);
    procedure analyse;
    procedure reset;
    procedure do_simul(t:string;val:integer);
    procedure gere_sim(s:string;val:integer);
    procedure redraw;
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

  {$R *.dfm}

procedure Tform1.redraw;
begin
//
end;

Procedure Tform1.load_bmp(p:pentry);
var bmp:Tbitmap;
begin
   bmp:=Tbitmap.create;
   bmp.Width:=33;
   bmp.Height:=33;
   bmp.Canvas.Brush.Color:=self.Color;
   bmp.Canvas.FillRect(Rect(0,0,33,33));
   form1.Canvas.Draw(p^.X,p^.Y,bmp);

   bmp.loadfromFile(extractfilepath(Application.exename)+'img\'+p^.device+'.bmp');
   bmp.Transparent :=true;
   bmp.TransparentColor:=clFuchsia;
   self.canvas.Font.Name:='Arial';
   self.canvas.font.Color:=clblack;
   self.canvas.Font.Size:=8;
   self.canvas.Font.Style:=[fsBold];
   self.Canvas.brush.Color:=self.color;
   self.Canvas.Brush.Style:=bsclear;
   self.Canvas.Pen.Mode:=pmCopy;
   if (pos('LMP',p^.device)>0) or (pos('REL',p^.device)>0) then self.Canvas.TextOut(p^.X+10,p^.Y-10,p^.letter) else  self.Canvas.TextOut(p^.X+10,p^.Y-4,p^.letter);

   bmp.Canvas.Pen.Color:=clFuchsia;

   form1.Canvas.Draw(p^.X,p^.Y,bmp);
   bmp.free;
end;


Procedure Tform1.gere_sim(s:string;val:integer);
var p:pentry;
    c:char;

begin

        p:=schema.l.Items[strtoint(s)];
        if p^.device ='P' then exit;
        if p^.device ='N' then exit;


        if (pos('NF', p^.device ) > 0) or (pos('NO', p^.device) >0) then if p^.device[3]='0' then p^.device[3]:='1' else p^.device[3]:='0';

        if val>5 then c:='1' else c:='0';
        if (pos('KF', p^.device ) > 0) or (pos('KO', p^.device) >0) then p^.device[3]:=c;


        self.load_bmp(p);
        memo2.Lines:=schema.show_entries;

end;

procedure Tform1.simul_letter(Sender: TObject);
var v:integer;
begin
   if (sender as Tcheckbox).Checked then v:=10 else v:=0;
   do_simul((sender as Tcheckbox).caption,v);
end;

procedure Tform1.do_simul(t:string;val:integer);
var l:Tlist;
i:integer;
p: pentry;
begin
 l:=Tlist.create;
 l:=schema.trouve_by_letter(t);
 for i := 0 to l.Count-1 do begin
   p:=l[i];
   gere_sim(inttostr(p^.num),val);
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
var i,j:integer;
    v1,v2:double;
    pp:pentry;
    bmp:Tbitmap;
    change1:boolean;
    change2:boolean;
begin

bmp:=Tbitmap.create;

for i:=0 to self.schema.l.Count-1 do begin
    pp:=self.schema.l[i];
    if (pos('LMP',pp^.device) > 0) or (pos('REL',pp^.device) > 0 )then begin

      if dico['V('+inttostr(pp^.pin1)+')']='' then dico['V('+inttostr(pp^.pin1)+')']:='0,0';
      if dico['V('+inttostr(pp^.pin2)+')']='' then dico['V('+inttostr(pp^.pin2)+')']:='0,0';
      v1:= strtofloat(dico['V('+inttostr(pp^.pin1)+')']);
      if pp^.pin2=0 then v2:= 0.0 else v2:=strtofloat(dico['V('+inttostr(pp^.pin2)+')']);

      change1 :=(v1-v2>5) and (pp^.device[4]='0');
      if change1 then pp^.device[4]:='1';

      change2 :=(v1-v2<1) and(pp^.device[4]='1');
      if change2 then pp^.device[4]:='0';
      if change1 or change2 then begin
      self.load_bmp(pp);

      //memo2.Lines.Add(pp^.letter);
      if pos('REL',pp^.device) > 0 then
        begin

          memo2.lines.add(pp^.letter+ inttostr(round(v1-v2)));
          do_simul(pp^.letter, round(v1-v2));
        end;

      continue;
      end;



    end;
end;

bmp.free;

end;

procedure Tform1.relie(a,b:string;mode:boolean);
var id_deb,id_fin:integer;

    t:Tstringlist;
    x1,y1,x2,y2, z1:integer;
    s:string;
    p:Pentry;

begin


  if a='' then exit;
  if a='-' then exit;
  if b='' then exit;
  if b='-' then exit;


  id_deb:=strtoint(trim(a));
  id_fin:=strtoint(trim(b));

  x1:=schema.trouve_by_id(id_deb).X;
  y1:=schema.trouve_by_id(id_deb).Y+33 div 2;
  x2:=schema.trouve_by_id(id_fin).X;
  y2:=schema.trouve_by_id(id_fin).Y+33 div 2;

  if x1>x2 then begin
      z1:=x2;  x2:=x1;  x1:=z1;
      z1:=y2;  y2:=y1;  y1:=z1;

      //z1:=id_deb; id_deb:=id_fin; id_fin:=z1;
  end;


  if (mode=true) then schema.add_link(id_deb,id_fin);

  self.memo2.lines:=schema.show_entries;
  self.memo2.lines.add(inttostr(id_deb)+inttostr(id_fin));

  memo2.Lines:=schema.show_entries;
  memo1.Lines:=schema.show_cx;

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
self.placer.Checked:=true;
self.placerClick(self);

for i:=1 to 10 do begin
  ck:= Tradiobutton.Create(self.box_check);
  ck.Name:='int'+chr(64+i);
  ck.Parent := self.box_check;
  ck.Visible:=true;
  ck.Caption:=chr(64+i);
  ck.Tag := i;
  ck.Width:=27;
  ck.left:=(i-1)*30;
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
  ck2.left:=(i-1)*30;
  ck2.OnClick:=simul_letter;


end;

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

self.box_check.Height:=self.box_check.Controls[0].Height;
self.box_check2.Height:=self.box_check2.Controls[0].Height;
self.box_check2.Hide;

isSimulate:=false;
schema:=Tschema.create;
dico:=TableauAssociatif.Create;
dir:=ExtractFilePath(Application.ExeName);
//self.Memo3.Lines.LoadFromFile(dir+'circuits\simple.cir');
//memo2.clear;

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
   c:char;
   p:pEntry;
   s:string;
   ck:Tradiobutton;

   begin
  try
    if choix=-1 then exit;
    Bmp:=Tbitmap.create;

     X := (X div 50) * 50;
     Y := (Y div 50) * 50;

    if isSimulate then begin
         exit;
    end;

    if isPlacing then begin
        //if (choix<>7) then if (X < 100) then exit;
        if schema.dejala(X,Y)then exit;
        schema.add_entry(X,Y,choix,letter);
        p:=self.schema.l[self.schema.l.count-1];
        load_bmp(p);
        memo2.Lines := schema.show_entries;
        if choix=5 then begin
          ck:=Tradiobutton.create(self.box_check);
          ck.parent:=self.box_check;
          ck.Caption:= p^.letter;
          ck.OnClick:=set_letter;
          ck.Left:=30*(self.box_check.ComponentCount);
        end;
        exit;
  end;
  //binding
  if isBinding then deb:=schema.trouve_composant_node(X,Y);

  finally begin
    bmp.free;

  end;
    end;
  end;


procedure TForm1.SpeedButton1Click(Sender: TObject);

begin

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

  if isBinding then begin

  if deb='-' then exit;
  if deb='' then exit;

  fin:=schema.trouve_composant_node(X,Y);
  if deb=fin then exit;
  if fin='-' then exit;

  self.relie(deb,fin,true);
  deb:='-';
  fin:='-'
  end;
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
var i:integer;
    p:pentry;
begin
self.placer.Checked:=true;
self.placerClick(self);
choix:=-1;
self.Fichier1.Enabled:=true;
isSimulate:=false;
timer1.Enabled:=false;

for i:=0 to self.box_check2.ControlCount-1 do (self.box_check2.Controls[i] as Tcheckbox).Checked:=false;
for i:= 0 to schema.l.Count-1 do begin
   p:=schema.l[i];
   if p^.device='LMP1' then  p^.device:='LMP0';
   if p^.device='REL1' then  p^.device:='REL0';
   if p^.device='NO1' then  p^.device:='NO0';
   if p^.device='NF1' then  p^.device:='NF0';
   if p^.device='KO1' then  p^.device:='KO0';
   if p^.device='KF1' then  p^.device:='KF0';
   self.load_bmp(p);
end;
self.box_check2.Visible:=false;
self.box_check.Visible:=true;
end;

procedure TForm1.Simuler1Click(Sender: TObject);

var s, ss:string;
    t:Tstringlist;

begin
self.Fichier1.Enabled:=false;
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
raw_readtxt(s,dir,dico);
timer1.Enabled:=false;
analyse;
spicing:=false;


end;

procedure TForm1.Enregistrer1Click(Sender: TObject);
begin
self.SaveDialog1.FileName:='*.bin';
self.SaveDialog1.InitialDir:=dir+'circuits\';
if self.SaveDialog1.Execute then schema.savetofile(self.SaveDialog1.FileName);
end;

procedure TForm1.Nouveau1Click(Sender: TObject);
begin
self.reset;
end;

procedure TForm1.Ouvrir1Click(Sender: TObject);
var p:pentry;
    s,p2:string;
    i:integer;
    t:Tstringlist;
begin
t:=Tstringlist.create;
opendialog1.InitialDir:=dir+'circuits\';
self.openDialog1.FileName:='*.bin';
if self.OpenDialog1.Execute then begin
   self.reset;
   schema.loadfromfile(self.OpenDialog1.FileName);

for i:=0 to schema.l.Count-1 do begin
  p := schema.l[i];
  self.load_bmp(p);
end;
for i:=0 to schema.cx.Count-1 do begin
    p2 := schema.cx[i];
    split(':',p2,t);
  self.relie(t[0] ,t[1],false);
end;

memo2.Lines:=schema.show_entries;
end;
t.free;
end;

procedure Tform1.reset;
var bmp:Tbitmap;
    i:integer;
begin
self.placer.Checked:=true;
self.placerClick(self);
letter:='A';
(self.box_check.Controls[0] as Tradiobutton).Checked:=true;
for i:=10 to self.box_check.ControlCount-1 do  self.box_check.Controls[i].Destroy;
for i:=0 to self.box_check2.ControlCount-1 do (self.box_check2.Controls[i] as Tcheckbox).Checked:=false;

self.box_check2.Visible:=false;
self.box_check.Visible:=true;
schema.free;

dico.Free;
schema:=Tschema.create;
dico:=TableauAssociatif.Create;
isSimulate:=false;
isBinding:=false;
isPlacing:=false;
spicing:=false;
memo2.Clear;
memo1.clear;
//effacer l'ecran


   bmp:=Tbitmap.create;
   bmp.Width:=self.Width;
   bmp.Height:=self.Height;
   bmp.Canvas.Brush.Color:=self.Color;
   bmp.Canvas.FillRect(Rect(0,0,self.Width,self.height));
   form1.Canvas.Draw(0,0,bmp);
   bmp.free;
end;

procedure TForm1.placerClick(Sender: TObject);
begin
isPlacing:=true;
isBinding:=false;
end;

procedure TForm1.RadioButton1Click(Sender: TObject);
begin
isPlacing:=false;
isBinding:=true;
end;

end.

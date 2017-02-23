unit schema_utils;
interface

uses
  Classes, SysUtils, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,tabassoc;

type
  Tlink = record
     de:integer;
     a: integer;
  end;
  Plink =^Tlink;
  TDevice = record
     Name : string;
     broches : integer;
   end;

  Tentry  = record
     num:integer;
     X: integer;
     Y: integer;
     device:string;
     choix:integer;
     broches : integer;
     _broches : integer;
     pin1: integer;
     pin2: integer;
     letter: shortstring;

  end;



  Tschema = class(Tobject)
       l:Tlist;
       cx:Tlist;
       public
       alim:boolean;
       nb_noeuds:integer;
       constructor create;
       destructor destroy; override;
       procedure add_entry(X,Y,choix:integer;letter:shortstring);
       function trouve_composant(X,Y:integer):string;
       function trouve_composant_node(X,Y:integer):string;
       function trouve_composant_node2(X,Y:integer):integer;
       function show_entries:TstringList;
       function show_entry(e:Tentry; s:TMemo):TstringList;
       function dejala(X,Y:integer):boolean;
       function dejala2(X,Y:integer):boolean;
       function trouve_by_id(id:integer):Tentry;
       procedure add_link(de,a:integer);
       function donne_cx(num:integer):string;
       function gen_netlist:Tstringlist;
       function trouve_by_letter(letter:shortstring):Tlist;
       procedure savetofile(fn:string);
       procedure loadfromfile(fn: string);
  end;

PEntry = ^TEntry;

const
   Devices : array[0..7] of TDevice =
   (
     (Name : 'P'; broches : 1),
     (Name : 'N'; broches : 1),
     (Name : 'NF0'; broches : 2),
     (Name : 'NO0'; broches : 2),
     (Name : 'LMP0'; broches : 2),
     (Name : 'REL0'; broches : 2),
     (Name : 'KF0'; broches : 2),
     (Name : 'KO0'; broches : 2)

   ) ;

procedure Split(Delimiter: Char; Str: string; ListOfStrings: TStrings) ;

implementation

procedure Split(Delimiter: Char; Str: string; ListOfStrings: TStrings) ;
begin
   ListOfStrings.Clear;
   ListOfStrings.Delimiter       := Delimiter;
   ListOfStrings.DelimitedText   := Str;
end;

procedure Tschema.loadfromfile(fn: string);

var i,j,n,m,de,a :integer;
    p:pEntry;
    p2:plink;
    tt:Tstringlist;
    t:Tentry;
    f:textfile;
    s:string;
begin
   assignfile(f,fn);
   reset(f);

   try
     tt:=Tstringlist.create;
     readln(f,n);
     readln(f,m);
     self.nb_noeuds:=m;
     for i:=0 to n-1 do begin
      new(p);
      readln(f,s);
      Split(':',s,tt);
      //Writeln(f,p^.num,':',p^.X,':',p^.Y,':',p^.device,':',p^.choix,':',p^.broches,':',p^._broches,':',p^.pin1,':',p^.pin2,':',p^.letter);
      p^.num:=strtoint(tt[0]);
      p^.X:=strtoint(tt[1]);
      p^.Y:=strtoint(tt[2]);
      p^.device:=tt[3];
      p^.choix:=strtoint(tt[4]);
      p^.broches:=strtoint(tt[5]);
      p^._broches:=strtoint(tt[6]);
      p^.pin1:=strtoint(tt[7]);
      p^.pin2:=strtoint(tt[8]);
      p^.letter:=tt[9];

      l.Add(p);
     end;

     readln(f,m);

     for i:=0 to m-1 do begin
       new(p2);
       readln(f,de);
       p2^.de:=de;
       readln(f,a);
       p2^.a:=a;
       cx.Add(p2);
     end;


   finally
      closefile(f);
      tt.free;
   end;

end;


procedure Tschema.savetofile(fn: string);

var i,n,m :integer;
    p:pEntry;
    p2:plink;
    t:tentry;
    f:textfile;

begin
   assignfile(f,fn);
   rewrite(f);
   n:=l.count;
   try
     Writeln(f,n);
     m:=self.nb_noeuds;
     Writeln(f,m);
     for i:=0 to n-1 do begin
      p:=l[i];
      Writeln(f,p^.num,':',p^.X,':',p^.Y,':',p^.device,':',p^.choix,':',p^.broches,':',p^._broches,':',p^.pin1,':',p^.pin2,':',p^.letter);
     end;
     n:=cx.count;
     writeln(f,n);
     for i:=0 to n-1 do begin
        p2:=cx[i];
        writeln(f,p2^.de);
        writeln(f,p2^.a);
     end;


   finally
     closefile(f);
   end;

end;

function Tschema.gen_netlist:Tstringlist;
var i:integer;
    p:pEntry;
    s:string;
begin
result:=Tstringlist.create;
result.Add('MrT sim-spice');
for i:=0 to self.l.Count-1 do begin
   p:=l[i];
   if p^.device = 'P' then s:='V1 1 0 10V';
   if p^.device = 'N' then continue;
   if (p^.device = 'NO0') or (p^.device = 'NF1') then result.Add('R'+inttostr(p^.num)+' '+inttostr(p^.pin1)+' '+inttostr(p^.pin2)+' 1e9');
   if (p^.device = 'NF0') or (p^.device = 'NO1') then result.Add('R'+inttostr(p^.num)+' '+inttostr(p^.pin1)+' '+inttostr(p^.pin2)+' 1');
   if (p^.device = 'KO0') or (p^.device = 'KF1') then result.Add('R'+inttostr(p^.num)+' '+inttostr(p^.pin1)+' '+inttostr(p^.pin2)+' 1e9');
   if (p^.device = 'KF0') or (p^.device = 'KO1') then result.Add('R'+inttostr(p^.num)+' '+inttostr(p^.pin1)+' '+inttostr(p^.pin2)+' 1');
   if (pos('LMP',p^.device)>0) then result.Add('R'+inttostr(p^.num)+' '+inttostr(p^.pin1)+' '+inttostr(p^.pin2)+' 500');
   if (pos('REL',p^.device)>0) then result.Add('R'+inttostr(p^.num)+' '+inttostr(p^.pin1)+' '+inttostr(p^.pin2)+' 500');



end;
if s<>'' then result.add(s);
result.add('.op');
end;

constructor Tschema.create;
begin
  l:=Tlist.create;
  cx:=Tlist.create;
end;

destructor Tschema.destroy;
begin
self.l.Free;
self.cx.Free;
inherited;

end;

procedure Tschema.add_link(de,a:integer);
var
    deb,fin,temp:tentry;
    p:pentry;
    p2:plink;
begin

    deb:=trouve_by_id(de);
    fin:=trouve_by_id(a);

    if not self.dejala2(de,a)  then begin
    new(p2);
    p2^.de:=de;
    p2^.a:=a;
    cx.Add(p2);
    end;

    if deb.device='P' then begin
      fin.pin1:=deb.pin1;
      p:=l[a];
      p^:=fin;
      exit;
    end;

    if fin.device='N' then begin
      deb.pin2:=fin.pin1;
      p:=l[de];
      p^:=deb;
      exit;
    end;


    begin
    //serie
    if (fin.device='LMP0') or (fin.device='REL0') then begin
      deb.pin2:=fin.pin1;
      p:=l[de];
      p^:=deb;
    end else begin
    fin.pin1:=deb.pin2;
      p:=l[a];
      p^:=fin;
    end;
   end;

end;

function Tschema.show_entries:TstringList;
var p : Pentry;
    i:integer;

begin

   result:=TstringList.create;
   for i:=0 to l.Count-1 do begin
      p:=l[i];
      result.Add(inttostr(p^.X)+':'+inttostr(p^.Y)+':'+p^.device);
   end;

end;
function Tschema.dejala(X,Y:integer):boolean;
var res:boolean;
    p : Pentry;
    i:integer;
begin
 res:=false;
 for i:=0 to self.l.count-1 do begin
      new(p);
      p:=l.Items[i];
      if (p^.X =X) and (p^.Y =Y) then
      begin
          res:=true;
          break;
      end;
 end;
 result:=res;
end;


function Tschema.dejala2(X,Y:integer):boolean;
var res:boolean;
    p : Plink;
    i:integer;
begin
 res:=false;
 for i:=0 to self.cx.count-1 do begin
      new(p);
      p:=l.Items[i];
      if (p^.de =X) and (p^.a =Y) or (p^.a =X) and (p^.de =Y)then
      begin
          res:=true;
          break;
      end;
 end;
 result:=res;
end;


procedure Tschema.add_entry(X,Y,choix:integer;letter:shortstring);
var p : Pentry;
    e: Tentry;
begin
   if self.dejala(X,Y) then exit;
   if (choix=0) and (alim) then exit;
   if not alim then if choix=0 then alim:=true;

   e.num:=l.Count;


   if choix=0 then e.letter:='P';
   if choix=1 then e.letter:='N';

   if (choix=2) or (choix=3) then begin
   if choix=2 then e.letter:='/'+letter;
   if choix=3 then e.letter:=letter;
   if pos('R',letter)>0 then choix:=choix+4;
   end;

   e.device:=devices[choix].Name;

   if choix=4 then e.letter:= e.device[1]+inttostr(e.num);
   if choix=5 then e.letter:= e.device[1]+inttostr(e.num);



   e.choix:=choix;
   e.X:=X;
   e.Y:=Y;
   e.broches:=devices[choix].broches;
   self.nb_noeuds := self.nb_noeuds+e.broches;
   e._broches := self.nb_noeuds;

   if (choix=0) or (choix=1) then begin
     if choix =0 then begin e.pin1 :=1; e.pin2:=-1; end;
     if choix =1 then begin e.pin1 :=0; e.pin2:=-1; end;

   end else begin
     e.pin1 := self.nb_noeuds-1;
     e.pin2 := self.nb_noeuds;
   end;

   new(p);
   p^:=e;
   l.Add(p);


end;
function Tschema.trouve_by_id(id:integer):Tentry;
var i:integer;
    p:Pentry;
begin
 new(p);
 p:=l.Items[id];
 result:=p^;
end;

function Tschema.trouve_by_letter(letter:shortstring):Tlist;
var i:integer;
    p:Pentry;
begin
   result:=Tlist.create;
   for i:=0 to l.count-1 do begin
     p:=l[i];
     if pos(letter,p^.letter)>0 then result.Add(p);
   end;
end;


function Tschema.trouve_composant_node2(X,Y:integer):integer;
var i:integer;
    p:Pentry;
    res:integer;
begin
   res := -1;
   for i:=0 to l.count-1 do begin
      //new(p);
      p:=l.Items[i];
      if (p^.X = X) and (p^.Y = Y) then
      begin
          res:= p^.num;
      end;
   end;

   result:= res;

end;

function Tschema.trouve_composant_node(X,Y:integer):string;
var i:integer;
    p:Pentry;
    res:string;
begin
   res := '-';
   for i:=0 to l.count-1 do begin
      //new(p);
      p:=l.Items[i];
      if (p^.X = X) and (p^.Y = Y) then
      begin
          res:= inttostr(p^.num);
      end;
   end;

   result:= res;

end;

function Tschema.donne_cx(num:integer):string;
var res:string;
    p:Pentry;
    i:integer;

begin
  res:='';
  p:=l.Items[num];
  for i :=  (p^._broches-p^.broches+1) to  (p^._broches) do
   res :=res+':'+inttostr(i);

  result:=res;



end;

function Tschema.trouve_composant(X,Y:integer):string;
var i:integer;
    p:Pentry;
    res:string;
begin

   for i:=0 to l.count-1 do begin
      //new(p);
      p:=l.Items[i];
      if (p^.X = X) and (p^.Y = Y) then
      begin
          res:= p^.device+'-'+inttostr(p^.num);
      end;
   end;
   if res ='' then res:='-';
   result:= res;

end;
function Tschema.show_entry(e:Tentry; s:TMemo):TstringList;
begin
   s.Lines.Add(inttostr(e.X)+':'+inttostr(e.Y)+':'+e.device+':'+inttostr(e.pin1)+':'+inttostr(e.pin2));
end;


end.


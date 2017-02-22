unit schema_utils;



interface

uses
  Classes, SysUtils, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type
   TDevice = record
     Name : string;
     broches : integer;
   end;

  Tlink = record
     de: integer;
     a : integer;
   end;

  Tentry = record
     num:integer;
     X: integer;
     Y: integer;
     device:string;
     broches : integer;
     _broches : integer;
     pin1: integer;
     pin2: integer;
     letter: shortstring;
  end;



  Tschema = class(Tobject)
       l:Tlist;

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
       function trouve_by_id(id:integer):Tentry;
       procedure add_link(de,a:integer);
       function donne_cx(num:integer):string;
       function gen_netlist:Tstringlist;
       function trouve_by_letter(letter:shortstring):Tlist;
  end;

PEntry = ^TEntry;
Plink = ^Tlink;
const
   Devices : array[0..4] of TDevice =
   (
     (Name : 'P'; broches : 1),
     (Name : 'N'; broches : 1),
     (Name : 'NF0'; broches : 2),
     (Name : 'NO0'; broches : 2),
     (Name : 'LMP0'; broches : 2)
   ) ;

procedure Split(Delimiter: Char; Str: string; ListOfStrings: TStrings) ;

implementation

procedure Split(Delimiter: Char; Str: string; ListOfStrings: TStrings) ;
begin
   ListOfStrings.Clear;
   ListOfStrings.Delimiter       := Delimiter;
   ListOfStrings.DelimitedText   := Str;
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
   if p^.device = 'NO0' then result.Add('R'+inttostr(p^.num)+' '+inttostr(p^.pin1)+' '+inttostr(p^.pin2)+' 1e9');
   if p^.device = 'NF0' then result.Add('R'+inttostr(p^.num)+' '+inttostr(p^.pin1)+' '+inttostr(p^.pin2)+' 1');
   if p^.device = 'NO1' then result.Add('R'+inttostr(p^.num)+' '+inttostr(p^.pin1)+' '+inttostr(p^.pin2)+' 1');
   if p^.device = 'NF1' then result.Add('R'+inttostr(p^.num)+' '+inttostr(p^.pin1)+' '+inttostr(p^.pin2)+' 1e9');
   if p^.device = 'LMP0' then result.Add('R'+inttostr(p^.num)+' '+inttostr(p^.pin1)+' '+inttostr(p^.pin2)+' 500');
   if p^.device = 'LMP1' then result.Add('R'+inttostr(p^.num)+' '+inttostr(p^.pin1)+' '+inttostr(p^.pin2)+' 500');


end;
if s<>'' then result.add(s);
result.add('.op');
end;

constructor Tschema.create;
begin
  l:=Tlist.create;
end;

destructor Tschema.destroy;
begin
self.l.Free;
inherited;
end;

procedure Tschema.add_link(de,a:integer);
var
    deb,fin,temp:tentry;
    p:pentry;
begin
    deb:=trouve_by_id(de);
    fin:=trouve_by_id(a);

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

    //derivation
    if deb.X = fin.X then
    begin
      if fin.device='LMP0' then
      deb.pin2:=fin.pin1;
      p:=l[de];
      p^:=deb;
    end

    else
    begin
    //serie
    if fin.device='LMP0' then begin
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
    res:TstringList;
begin
   res:=TstringList.create;
   for i:=0 to l.Count-1 do begin
      new(p);
      p:=l.Items[i];
      res.Add(inttostr(p^.X)+':'+inttostr(p^.Y)+':'+p^.device+':'+inttostr(p^._broches) +':'+inttostr(p^.pin1)+':'+inttostr(p^.pin2)+': '+p^.letter);
   end;
   result:=res;
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


procedure Tschema.add_entry(X,Y,choix:integer;letter:shortstring);
var p : Pentry;
    e: Tentry;
begin
   if self.dejala(X,Y) then exit;
   if (choix=0) and (alim) then exit;
   if not alim then if choix=0 then alim:=true;

   if choix=2 then e.letter:='/'+letter;
   if choix=3 then e.letter:=letter;

   e.X:=X;
   e.Y:=Y;
   e.device:=devices[choix].Name;
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
   e.num:=l.Count;
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


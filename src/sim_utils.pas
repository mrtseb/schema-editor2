unit sim_utils;


interface
uses tabassoc, sysutils, classes,strutils;
procedure raw_read(fn, dir: string);                                                                                               
procedure raw_readtxt(fn, dir: string; dico:Tableauassociatif);


implementation



procedure Split(Delimiter: Char; Str: string; ListOfStrings: TStrings) ;
begin
   ListOfStrings.Clear;
   ListOfStrings.Delimiter       := Delimiter;
   ListOfStrings.DelimitedText   := Str;
end;

procedure raw_readtxt(fn, dir: string; dico:Tableauassociatif);
var f,f2:textfile;
    s,ss:string;
    t,tt:tstringlist;
    cles:Tstringlist;
    i:integer;
begin
    try
      t:=tstringlist.create;
      tt:=tstringlist.create;
      cles:=tstringlist.create;
      assignfile(f,dir+'circuits\temp.raw');
      assignfile(f2,dir+'circuits\temp.txt');
      reset(f);
      rewrite(f2);
      i:=0;

      while not eof(f) do begin
         readln(f,s);

         if pos ('No. Variables:',s) > 0 then begin
         split(':',s,t);
         writeln(f2,t[2]);
         end;

         if pos (#9,s) > 0 then begin
         if pos ('alues',s) > 0 then i:=0;
         split(#9,s,t);
         //writeln(f2,t.count);
         if t.count=3 then begin
             cles.Add(t[t.count-2]);
             writeln(f2,t[t.count-2]);
         end;
         if t.count <3 then
           begin
              if cles.Count=0 then exit;
              split('.',t[t.count-1],tt);
              s:=tt[0]+','+tt[1];
              dico.ajoutElement(cles[i],s);
              writeln(f2,cles[i],' ',t[t.count-1]);
              i:=i+1;
           end;
        end;

      end;


    finally
      t.Free;
      tt.free;
      closefile(f2);
      closefile(f);
    end;

end;


procedure raw_read(fn, dir: string);
var
    flag: boolean;
    f2:textfile;
    f:Tfilestream;
    t2:Tstringlist;
    d:widechar;
    dd:single;
    i,j,vr,points:integer;
    k:byte;
    s,st:string;
    fin:boolean;
begin

    assignfile(f2,dir+'circuits\temp.txt');
    rewrite(f2);
    t2:=Tstringlist.create;
    f:=Tfilestream.create(fn, fmopenread);
    i:=0;
    s:='';
    try

     while f.position < f.Size do begin
     i:=i+1;
     f.readbuffer(d,sizeof(d));
     if (d<>#0) and (d<>#10) then begin s:=s+d; end;

          if d=chr(10) then begin
            //writeln(f2,s);

            if pos('No. Variables:',s)>0 then
            begin
             Split(' ',s,t2);
             st:=t2[2];
             vr:=strtoint(trim(st));
             writeln(f2,vr);
            end;
            if pos('No. Points:',s)>0 then
            begin
              Split(' ',s,t2);
              st:=t2[2];
              points:=strtoint(trim(st));
            end;



            if pos(#9,s) > 0  then
            begin
              Split(#9,s,t2);
              st:=t2[1];
              writeln(f2,st);
            end;

            if pos('Binary:',s)>0 then
            begin
              flag:=false;
              //writeln(f2,'N°: '+inttostr(i)+' pos: '+inttostr(f.position)+' size: '+inttostr(f.size)+' variables: '+inttostr(vr)+' points: '+inttostr(points)+' octets: '
              //+inttostr((f.size-f.position) div (points*vr)));
              break;
            end;
            s:='';
     end;//

     end;//


     //for i:=1 to 4 do f.Read(d,sizeof(d));

     while f.position < f.Size do begin

     f.Read(dd,sizeof(dd));
     writeln(f2,dd);



     end;


    finally
      closefile(f2);
      f.Free;
    end;

end;
end.



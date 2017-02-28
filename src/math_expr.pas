unit math_expr;

interface

type

// *** pile g�n�rique ***
  TGVStack = class(TObject)
  private
    fItems: array of string;
    //fError: TGVErrors; // gestionnaire des erreurs
    fCount: Integer; // nombre d'�l�ments
    fCapacity: Integer; // capacit� actuelle
    //fOnNotify: TGVStackEvent; // notification
    procedure Expand; // expansion si n�cessaire
    function GetCapacity: Integer; // capacit� actuelle
    function GetItem(N: Integer): string;  // acc�s � un �l�ment
    procedure SetCapacity(const Value: Integer); // fixe la capacit�
    procedure SetItem(N: Integer; AValue: string);
  protected
    //procedure Notify(Action: TGVStackNotification); virtual; // notification
    procedure DoPush(const Value: string); // empilement
    function DoPop: string; // d�pilement
  public
    constructor Create; overload; // cr�ation
    destructor Destroy; override; // destruction
    procedure Clear; // nettoyage
    function IsEmpty: Boolean;  // pile vide ?
    procedure Push(const Value: string); // empilement avec notification
    function Pop: string; // d�pilement avec notification
    function Peek: string; // sommet de la pile
    procedure Drop; // sommet de la pile �ject�
    procedure Dup; // duplication au sommet de la pile
    procedure Swap; // inversion au sommet de la pile
    procedure Over; // duplication de l'avant-dernier
    procedure Rot; // rotation au sommet de la pile
    procedure Shrink; // contraction de la pile
    function Needed(Nb: Integer): Boolean; // nombre d'�l�ments d�sir�s
    property Count: Integer read fCount default 0; // compte des �l�ments
    // capacit� de la pile
    property Capacity: Integer read GetCapacity write SetCapacity;

    // acc�s direct � un �l�ment
    property Item[N: Integer]: string read GetItem write SetItem; default;
    // notification d'un changement
    //property OnNotify: TGVStackEvent read fOnNotify write fOnNotify;
    // notification d'une erreur
    //property Error: TGVErrors read fError write fError;
end;

implementation


end.

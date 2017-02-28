unit math_expr;

interface

type

// *** pile générique ***
  TGVStack = class(TObject)
  private
    fItems: array of string;
    //fError: TGVErrors; // gestionnaire des erreurs
    fCount: Integer; // nombre d'éléments
    fCapacity: Integer; // capacité actuelle
    //fOnNotify: TGVStackEvent; // notification
    procedure Expand; // expansion si nécessaire
    function GetCapacity: Integer; // capacité actuelle
    function GetItem(N: Integer): string;  // accès à un élément
    procedure SetCapacity(const Value: Integer); // fixe la capacité
    procedure SetItem(N: Integer; AValue: string);
  protected
    //procedure Notify(Action: TGVStackNotification); virtual; // notification
    procedure DoPush(const Value: string); // empilement
    function DoPop: string; // dépilement
  public
    constructor Create; overload; // création
    destructor Destroy; override; // destruction
    procedure Clear; // nettoyage
    function IsEmpty: Boolean;  // pile vide ?
    procedure Push(const Value: string); // empilement avec notification
    function Pop: string; // dépilement avec notification
    function Peek: string; // sommet de la pile
    procedure Drop; // sommet de la pile éjecté
    procedure Dup; // duplication au sommet de la pile
    procedure Swap; // inversion au sommet de la pile
    procedure Over; // duplication de l'avant-dernier
    procedure Rot; // rotation au sommet de la pile
    procedure Shrink; // contraction de la pile
    function Needed(Nb: Integer): Boolean; // nombre d'éléments désirés
    property Count: Integer read fCount default 0; // compte des éléments
    // capacité de la pile
    property Capacity: Integer read GetCapacity write SetCapacity;

    // accès direct à un élément
    property Item[N: Integer]: string read GetItem write SetItem; default;
    // notification d'un changement
    //property OnNotify: TGVStackEvent read fOnNotify write fOnNotify;
    // notification d'une erreur
    //property Error: TGVErrors read fError write fError;
end;

implementation


end.

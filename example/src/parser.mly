%{
%}

%token <string> KEY
%token <string> STRING
%token <int> INT
%token <bool> BOOL
%token <string> COMMENT
%token EQUALS
%token EOF

%start <Config.t> config

%%

config:
  | entries = list(entry); EOF { entries }
;

entry:
  | c = COMMENT
    { Config.Comment c }
  | key = KEY; EQUALS; value = value
    { Config.Binding { loc = Loc.create $loc; key; value } }
;

value:
  | s = STRING { Config.String s }
  | i = INT    { Config.Int i }
  | b = BOOL   { Config.Bool b }
;

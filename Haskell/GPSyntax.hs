module GPSyntax where

import Graph

gpChars :: [Char]
gpChars = concat [ ['A'..'Z'] , ['a'..'z'] , ['0'..'9'] , ['_'] ]

keywords :: [String]
keywords = map fst hostColours ++ map fst gpTypes ++
           ["main", "if", "try", "then", "else", "or", "skip", "fail",
            "interface", "where", "injective", "true", "false",
            "and", "not", "edge", "empty", "indeg", "outdeg",
            "slength", "llength"]

data Colour = Uncoloured | Red | Green | Blue | Grey | Dashed | Any
  deriving (Ord, Eq, Show)

hostColours :: [ (String, Colour) ]
hostColours = [
    ("uncoloured", Uncoloured),
    ("red", Red),
    ("green", Green),
    ("blue", Blue), 
    ("grey", Grey),
    ("dashed", Dashed) ]

ruleColours :: [ (String, Colour) ]
ruleColours = ("any", Any) : hostColours

data VarType = IntVar | ChrVar | StrVar | AtomVar | ListVar
  deriving (Eq, Show)

instance Ord VarType where
    ListVar <= vt = vt == ListVar
    AtomVar <= vt = vt `elem` [ListVar, AtomVar]
    IntVar  <= vt = vt `elem` [IntVar, AtomVar, ListVar]
    StrVar  <= vt = vt `elem` [StrVar, AtomVar, ListVar]
    ChrVar  <= vt = vt `elem` [ChrVar, StrVar, AtomVar, ListVar] 

gpTypes :: [ (String, VarType) ]
gpTypes = [
    ("int", IntVar),
    ("char", ChrVar),
    ("string", StrVar),
    ("atom", AtomVar),
    ("list", ListVar) ]

type ProcName = String
type RuleName = String
type VarName = String
type NodeName = String
type EdgeName = String

-- GP Program ADTs
data GPProgram = Program [Declaration] deriving Show

data Declaration = Main [Expr]
                 | Proc ProcName [Declaration] [Expr]
                 | AstRuleDecl AstRule
                 | RuleDecl Rule
     deriving Show

-- data Main = Main [Expr] deriving Show

-- data Procedure = Procedure ProcName [Declaration] [Expr] deriving Show

data Expr = IfStatement Expr Expr Expr
          | TryStatement Expr Expr Expr
          | Looped Expr
          | Sequence [Expr]
          | ProcedureCall ProcName
          | RuleSet [RuleName]
          | ProgramOr Expr Expr
          | Skip
          | Fail
          deriving (Show, Eq)

-- -- Old data structures, for references purposes
-- data Command = Block Block
--              | IfStatement Block Block Block 
--              | TryStatement Block Block Block
--     deriving Show
-- 
-- data Block = ComSeq [Command]
--            | LoopedComSeq [Command]
--            | SimpleCommand SimpleCommand
--            | ProgramOr Block Block      
--     deriving (Show)
--       
-- data SimpleCommand = RuleCall [RuleName]
--                    | LoopedRuleCall [RuleName]
--                    | ProcedureCall ProcName
--                    | LoopedProcedureCall ProcName
--                    | Skip
--                    | Fail
--     deriving Show

-- GP Rule ADTs
type Variable = (VarName, VarType)
type NodeInterface = [(NodeKey, NodeKey)]
-- For bidirectional edges
type EdgeInterface = [(EdgeKey, EdgeKey)]

data Rule = Rule RuleName [Variable] (RuleGraph, RuleGraph) NodeInterface 
            EdgeInterface Condition deriving Show

data AstRule = AstRule RuleName [Variable] (AstRuleGraph, AstRuleGraph) 
               Condition  deriving Show
data AstRuleGraph = AstRuleGraph [RuleNode] [AstRuleEdge] deriving (Show,Eq)
data AstRuleEdge = AstRuleEdge EdgeName Bool NodeName NodeName RuleLabel deriving (Show, Eq)

-- Rule graph labels are lists of expressions.
type RuleGraph = Graph RuleNode RuleEdge
data RuleNode = RuleNode NodeName Bool RuleLabel deriving (Show, Eq)
data RuleEdge = RuleEdge EdgeName Bool RuleLabel deriving (Show, Eq)

type GPList = [RuleAtom]
data RuleLabel = RuleLabel GPList Colour deriving (Show, Eq)

data RuleAtom = Var Variable
              | Val HostAtom
              | Neg RuleAtom
              | Indeg NodeName
              | Outdeg NodeName
              -- RHS only
              | Llength GPList
              | Slength RuleAtom
              | Plus RuleAtom RuleAtom
              | Minus RuleAtom RuleAtom
              | Times RuleAtom RuleAtom
              | Div RuleAtom RuleAtom
              | Concat RuleAtom RuleAtom
    deriving (Show, Eq)

-- TODO: precedence of infix binary operators
data Condition = NoCondition
               | TestInt VarName
               | TestChr VarName
               | TestStr VarName
               | TestAtom VarName
               | Edge NodeName NodeName (Maybe RuleLabel)
               | Eq GPList GPList
               | NEq GPList GPList
               | Greater RuleAtom RuleAtom
               | GreaterEq RuleAtom RuleAtom
               | Less RuleAtom RuleAtom
               | LessEq RuleAtom RuleAtom
               | Not Condition
               | Or Condition Condition
               | And Condition Condition
    deriving Show

data HostNode = HostNode NodeName Bool HostLabel deriving Show
-- For graph isomorphism checking.
instance Eq HostNode where
    HostNode _ isRoot1 label1 == HostNode _ isRoot2 label2 =
        isRoot1 == isRoot2 && label1 == label2
instance Ord HostNode where
    HostNode _ isRoot1 label1 `compare` HostNode _ isRoot2 label2 =
        (isRoot1,label1) `compare` (isRoot2,label2)

data HostEdge = HostEdge NodeName NodeName HostLabel deriving Show

-- Host Graph ADTs
type HostGraph = Graph HostNode HostLabel
data AstHostGraph = AstHostGraph [HostNode] [HostEdge] deriving Show
data HostLabel = HostLabel [HostAtom] Colour deriving (Ord, Eq, Show)
data HostAtom = Int Int | Str String | Chr Char deriving (Ord, Eq, Show)

colourH :: HostGraph -> NodeKey -> Colour
colourH h n = c where HostNode _ _ (HostLabel _ c) = nLabel h n 

colourR :: RuleGraph -> NodeKey -> Colour
colourR r n = c where RuleNode _ _ (RuleLabel _ c) = nLabel r n 

-- isRootH :: HostGraph -> NodeId -> Bool 
-- isRootH h n = root where HostNode _ root _ = nLabel h n 

-- isRootR :: RuleGraph -> NodeId -> Bool
-- isRootR r n = root where RuleNode _ root _ = nLabel r n 
-- 
-- isBidirectional :: RuleGraph -> EdgeId -> Bool
-- isBidirectional r e = bi where RuleEdge _ bi _ = eLabel r e 

module OILR4.Config where

import System.Console.GetOpt

import OILR4.IR

import GPSyntax  -- for colours
import Mapping

import Data.List
import Data.Bits

-- OilrConfig represents the global configuration of the OILR machine
-- for the current program.

type Ind = Int  -- An OILR index is just an integer

          -- Disable standard optimisations
data Flag = NoOILR               -- switch off OILR indexing entirely
          | NoMatchSort          -- don't sort node matches by constrainedness
          | NoMultiInstr         -- don't emit instructions that bind more than a single element
          | NoSearchPlan         -- match nodes & edges individually
          | NoInline             -- don't inline procedures called from a single site
          | NoRecursion          -- don't apply looped rules recursively
          -- Output options
          | Dump String          -- dump an internal representation
          -- Compilation options
          | Compile32Bit         -- Generate 32 bit code
          -- Non-standard optimisations
          | UseOracle            -- Use the graph oracle
          | UseCompactIndex      -- Use a minimal set of OILR indices
          | UseAppendToIndex     -- Append to index instead of prepending
          -- OILR Runtime options
          | EnableDebugging
          | EnableParanoidDebugging
          | EnableExecutionTrace
    deriving (Eq, Show)

data OilrIndexBits = OilrIndexBits { bBits::Int
                                   , cBits::Int
                                   , oBits::Int
                                   , iBits::Int
                                   , lBits::Int
                                   , rBits::Int } deriving (Show, Eq)

indBits = OilrIndexBits 1 3 2 2 2 1
indCount (OilrIndexBits b c o i l r) = 1 `shift` (b+c+o+i+l+r)


data OilrConfig = OilrConfig { compilerFlags  :: [Flag]
                             , predicateRules :: [String]
                             , indexCount     :: Int
                             , physIndCount   :: Int
                             , logicalToPhys  :: Mapping Int Int     -- mapping of logical onto physical spaces
                             , packedSpaces   :: Mapping Int [Ind]   -- search spaces expressed as physical inds
                             , searchSpaces   :: Mapping Int [Ind]}  -- search spaces expressed as logical inds

colourIds :: Mapping Colour Int
colourIds = [ (Uncoloured, 0)
            , (Red       , 1)
            , (Blue      , 2)
            , (Green     , 3)
            , (Grey      , 4) ]
edgeColourIds :: Mapping Colour Int
edgeColourIds = [ (Uncoloured, 0) , (Dashed, 1) ]


configureOilrMachine :: [Flag] -> [OilrIR] -> OilrConfig
configureOilrMachine flags prog =
    OilrConfig { predicateRules = findPredicateRules prog 
               , compilerFlags  = flags
               , indexCount     = indCount indBits
               , searchSpaces   = []}



findPredicateRules :: [OilrIR] -> [Id]
findPredicateRules prog = concatMap preds prog
    where preds (IRProc _ _) = []
          preds (IRRule id r) = case filter hasMods r of
                                    [] -> [id]
                                    _ -> []
          hasMods (Change _ _) = True
          hasMods (Create _) = True
          hasMods (Delete _) = True
          hasMods _ = False


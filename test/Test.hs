module Test where

import System.Process (system)
import System.Exit (ExitCode)
import Data.Maybe

import Syntax
import DotPrinter
import SldTreePrinter
import GlobalTreePrinter
import Utils

import qualified CPD
import qualified GlobalControl as GC
import qualified Purification as P
import qualified OCanrenize as OC

import qualified SeqUnfold as SU
import qualified FullUnfold as FU
import qualified RandUnfold as RU

import qualified DTree as DT
import qualified DTResidualize as DTR

import qualified LogicInt as LI
import qualified List as L

--
-- Save a tree into pdf file.
--
printToPdf :: DotPrinter a => String -> a -> IO ExitCode
printToPdf name t = do
    let dotfilename = name ++ ".dot"
    let pdffilename = name ++ ".pdf"
    printTree dotfilename t
    system $ "dot -Tpdf '" ++ dotfilename ++ "' > '" ++ pdffilename ++ "'"

--
-- Open pdf file of a tree (using `zathura` pdf viewer).
--
openInPdf :: DotPrinter a => a -> IO ExitCode
openInPdf t = do
    let name = "/tmp/ukanrentesttree"
    openInPdfWithName name t

openInPdfWithName :: DotPrinter a => String -> a -> IO ExitCode
openInPdfWithName name t = do
    let dotfilename = name ++ ".dot"
    let pdffilename = name ++ ".pdf"
    printTree dotfilename t
    -- dot -Tpdf '$dot' > '$tmp_pdf_file'
    system $ "dot -Tpdf '" ++ dotfilename ++ "' > '" ++ pdffilename ++ "'"
    -- zathura '$pdf'
    system $ "zathura '" ++ pdffilename ++ "'"
    -- rm '$pdf' '$dot'
    system $ "rm '" ++ pdffilename ++ "' '" ++ dotfilename ++ "'"


ocanren filename goal = do
  let p = pur goal
  let name = filename ++ ".ml"
  OC.topLevel name "topLevelSU" Nothing p
  where
    pur goal = let
        (tree, logicGoal, names) = SU.topLevel goal
        f = DTR.topLevel tree
        (goal', names', defs) = P.purification (f, vident <$> reverse names)
      in (goal', names', (\(n1, n2, n3) -> (n1, n2, fromJust $ DTR.simplify n3)) <$> defs)

testRev2 = L.reverso $ fresh ["xs", "sx"] $
  call "reverso" [V "xs", V "sx"] &&& call "reverso" [V "sx", V "xs"]

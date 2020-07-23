{-# LANGUAGE DataKinds, FlexibleInstances, LiberalTypeSynonyms            #-}
{-# LANGUAGE MultiParamTypeClasses, TemplateHaskell, TypeSynonymInstances #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}
module Algebra.Field.Galois.Conway
       (Conway,
        ConwayPolynomial(..),
        addConwayPolynomials,
        conwayFile) where
import Algebra.Field.Galois.Internal
import Algebra.Prelude.Core
import Language.Haskell.TH           (DecsQ)
import Language.Haskell.TH.Syntax
import System.Directory

do
  dir <- runIO getCurrentDirectory
  conwayFile : _ <- runIO $
    filterM doesFileExist
    [ dir </> "halg-galois-fields" </> "data" </> "conway.txt"
    , "data" </> "conway.txt"
    , "halg-galois-fields" </> "data" </> "conway.txt"
    ]
  addDependentFile conwayFile
  dat <- tail . init . lines <$> runIO (readFile conwayFile)
  concat <$> mapM (buildInstance . head . parseLine) dat

-- | Macro to add Conway polynomials dictionary.
addConwayPolynomials :: [(Integer, Integer, [Integer])] -> DecsQ
addConwayPolynomials = liftM concat . mapM buildInstance

-- | Parse conway polynomial file and define instances for them.
--   File-format must be the same as
--   <http://www.math.rwth-aachen.de/~Frank.Luebeck/data/ConwayPol/index.html?LANG=en Lueback's file>.
conwayFile :: FilePath -> DecsQ
conwayFile fp = do
  dat <- tail . init . lines <$> runIO (readFile fp)
  addConwayPolynomials $ concatMap parseLine dat

{- Copyright (c) 2005 John Goerzen
<jgoerzen@complete.org>
Please see the COPYRIGHT file
-}

module Import where
import Config
import System.Directory
import MissingH.Printf
import MissingH.Maybe
import MissingH.Path
import MissingH.Cmd
import MissingH.Either
import Control.Exception
import Control.Monad
import Darcs
import Utils
import MissingH.Debian
import Text.ParserCombinators.Parsec
import Versions

importDsc dscname =
    let parsef fl =
            case split ' ' fl of
              [md5, size, fn] -> (md5, size, fn)
              _ -> error $ "Couldn't parse dsc file line " ++ fl
        in do dscf <- parseFromFile control dscname
              let dsc = forceEither dscf
              let package = forceMaybe . lookup "Source" dsc
              let debvers = forceMaybe . lookup "Version" dsc
              let files = map parsef . lines . forceMaybe . 
                              lookup "Files" $ dscf
              -- Figure out whether there is an upstream for this package.
              -- If so, import its tar.gz file.
              when (any (isSuffixOf "diff.gz") files) $
                   do let origtar = forceMaybe $
                                      find (isSuffixOf ".orig.tar.gz") files
                      importOrigTarGz 
                         
              

importOrigDir dirname_r package version =
    do (upstreamdir, _) <- getDirectories package
       createRepo upstreamdir
       checkVersion "UPSTREAM" package version upstreamdir
       cwd <- getCurrentDirectory
       let dirname = forceMaybe $ absNormPath cwd dirname_r 
       safeSystem "darcs_load_dirs" 
                      ["--wc=" ++ upstreamdir,
                       "--summary=Import upstream " ++ package ++ " version "
                        ++ version,
                       dirname]
       bracketCWD upstreamdir
         (safeSystem "darcs" ["tag", "-m", upstreamTag package version])

importOrigTarGz tgz_r package version = 
    do origcwd <- getCurrentDirectory
       let tgz = forceMaybe $ absNormPath origcwd tgz_r
       brackettmpdir ",,dbp-importorigtargz-XXXXXX" $ 
         (\tmpdir -> bracketCWD tmpdir $
           do safeSystem "tar" ["-zxSpf", tgz]
              let tmpabs = forceMaybe $ absNormPath origcwd tmpdir
              content <- getDirectoryContents tmpabs
              -- If it has more than one entry, this directory itself is
              -- source, since the tar didn't put things under one dir.
              -- Bad, bad tar.
              let origdir = case filter (\x -> x /= "." && x /= "..") content of
                              [dir] -> tmpabs ++ "/" ++ dir
                              _ -> tmpabs
              importOrigDir origdir package version
         )

-- | Create a Darcs repository at the given path, or do nothing if the
-- directory already exists.
createRepo :: FilePath -> IO ()
createRepo dir =
    do isdir <- doesDirectoryExist dir
       unless isdir $
          do createDirectory dir
             bracketCWD dir $ safeSystem "darcs" ["initialize"]

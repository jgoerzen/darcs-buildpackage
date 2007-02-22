{- Copyright (c) 2005 John Goerzen
<jgoerzen@complete.org>
Please see the COPYRIGHT file
-}

module Import where
import Config
import System.Directory
import Text.Printf
import Data.Maybe.Utils
import System.Path
import System.Cmd.Utils
import Data.Either.Utils
import System.Path.NameManip
import Data.Log.Logger
import Data.String
import Control.Exception
import Control.Monad
import Darcs
import Utils
import System.Debian
import System.Debian.ControlParser
import Data.List
import Text.ParserCombinators.Parsec
import Versions

importDsc dscname_r =
    let parsef fl =
            case split " " (strip fl) of
              [md5, size, fn] -> fn
              _ -> error $ "Couldn't parse dsc file line " ++ fl
        in do cwd <- getCurrentDirectory
              let dscname = forceMaybe . absNormPath cwd $ dscname_r
              dscf <- parseFromFile control dscname
              let dsc = forceEither dscf
              let package = strip . forceMaybe . lookup "Source" $ dsc
              let version = strip . forceMaybe . lookup "Version" $ dsc
              let (upsv, debv) = splitVer version
              let files = map parsef . filter (/= "") . map strip .
                              lines . forceMaybe . 
                              lookup "Files" $ dsc
              -- Figure out whether there is an upstream for this package.
              -- If so, import its tar.gz file.
              let hasupstream = any (isSuffixOf "diff.gz") files
              when hasupstream $
                   do let origtar = forceMaybe $
                                      find (isSuffixOf ".orig.tar.gz") files
                      importOrigTarGz ((dir_part dscname) ++ "/" ++ origtar)
                                      package upsv
              
              -- Now, handle Debian side of things.
              (upstreamdir, debiandir) <- getDirectories package
              createRepo debiandir
              checkv <- checkVersion "DEBIAN" package version debiandir
              if checkv
                 then do when hasupstream $ bracketCWD debiandir $ 
                           unless (debv == Nothing) $
                             safeSystem "darcs" 
                                ["pull", "--set-scripts-executable",
                                 "--no-set-default", "-a", 
                                 "--tags=^" ++ 
                                  quoteRe (upstreamTag package upsv) ++ "$",
                                 upstreamdir]
                         brackettmpdir ",,extract-XXXXXX" (\tmpd -> bracketCWD tmpd $
                           do safeSystem "dpkg-source" ["-x", dscname]
                              debsrcdir <- findSrc "."
                              safeSystem "darcs_load_dirs" 
                                ["--wc=" ++ debiandir,
                                 "--summary=Import Debian " ++ package ++
                                  " version " ++ version,
                                 debsrcdir])
                         bracketCWD debiandir $ 
                            safeSystem "darcs" ["tag", "-m",
                                                debianTag package version]
                 else infoM "main" $ "Debian version " ++ version ++
                        " already exists; not modifying."

findSrc :: String -> IO String
findSrc dir =
    do contents <- getDirectoryContents dir
       let fc = filter (\x -> x /= "." && x /= ".." && (not $ isSuffixOf "tar.gz" x)) contents
       return $ dir ++ "/" ++ head fc
                           
importOrigDir dirname_r package version =
    do (upstreamdir, _) <- getDirectories package
       createRepo upstreamdir
       checkv <- checkVersion "UPSTREAM" package version upstreamdir
       if checkv
          then do cwd <- getCurrentDirectory
                  let dirname = forceMaybe $ absNormPath cwd dirname_r 
                  safeSystem "darcs_load_dirs" 
                      ["--wc=" ++ upstreamdir,
                       "--summary=Import upstream " ++ package ++ " version "
                        ++ version,
                       dirname]
                  bracketCWD upstreamdir
                    (safeSystem "darcs" 
                     ["tag", "-m", upstreamTag package version])
          else infoM "main" $ "Not importing orig; version " ++ version ++
                 " already exists in repository."

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
    when (isLocalPath dir) $
         do isdir <- doesDirectoryExist dir
            unless isdir $
                do createDirectory dir
                   bracketCWD dir $ safeSystem "darcs" ["initialize"]

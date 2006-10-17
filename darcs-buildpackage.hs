{- Copyright (c) 2005 John Goerzen
<jgoerzen@complete.org>
Please see the COPYRIGHT file
-}

module Main where
import Config
import System.Environment
import System.Directory
import Import
import Logging
import Control.Exception
import Utils
import Versions
import MissingH.Logging.Logger
import MissingH.Cmd
import MissingH.IO.HVFS.Utils
import Darcs
import System.Posix.Files
import System.Cmd
import System.Exit
import Mirrors
import List

split :: Eq a => [a]
      -> [a]
      -> [[a]]

split glue xs = split' xs
    where
    split' [] = []
    split' xs = piece : split' (dropGlue rest)
        where (piece, rest) = breakOnGlue glue xs
    dropGlue = drop (length glue)

breakOnGlue :: (Eq a) => [a]
            -> [a]
            -> ([a],[a])

breakOnGlue _ [] = ([],[])
breakOnGlue glue rest@(x:xs)
    | glue `isPrefixOf` rest = ([], rest)
    | otherwise = (x:piece, rest') where (piece, rest') = breakOnGlue glue xs

main = do initLogging
          args <- getArgs
          let (dbp_args, rest) = partition (isPrefixOf "--dbp_builder=") (["--dbp_builder=debuild"] ++ args)
          let build_cmd = last $ split "=" $ last dbp_args
          ver <- getVerFromCL
          pkg <- getPkgFromCL
          let (upsv, debv) = splitVer ver
          case debv of
              Nothing -> infoM "main" "Debian-native package; not building upstream"
              Just dv -> do buildorig pkg upsv debv
          args <- getArgs
          buildenv <- try (getEnv "DBP_BUILDER")
          case buildenv of
            Right buildcmd -> safeSystem "/bin/sh" ["-c", buildcmd]
            Left _ -> safeSystem build_cmd (["-i_darcs", "-I_darcs"] ++ args)

-- Build the orig.tar.gz
buildorig pkg upsv debv =
    let tgzname = pkg ++ "_" ++ upsv ++ ".orig.tar.gz"
        origdirname = pkg ++ "-" ++ upsv ++ ".orig"
        in do
           e1 <- doesFileExist $ "../" ++ tgzname
           e2 <- doesDirectoryExist $ "../" ++ origdirname
           if e1 || e2
              then infoM "main" $ "Upstream file or directory already exists; not re-building"
              else do cwd <- getCurrentDirectory
                      (upstreamdir, _) <- getDirectories pkg
                      upsMirrors <- getMirrors "upstream" pkg
                      getItUps pkg upstreamdir upsMirrors
                      bracketCWD ".." $
                        do ec <- rawSystem "darcs" ["get", "--partial", 
                                "--set-scripts-executable",
                                "--tag=^" ++ 
                                 quoteRe (upstreamTag pkg upsv) ++ "$",
                                upstreamdir, origdirname]
                           case ec of
                               ExitSuccess -> do bracketCWD origdirname $
                                                  do safeSystem "darcs" ["dist"]
                                                     rename (origdirname ++ ".tar.gz") ("../" ++ tgzname)
                                                 recursiveRemove SystemFS origdirname
                               _ -> warningM "main" "WARNING: FOUND NO UPSTREAM SOURCE FOR PACKAGE, will build native (no-diff) package"

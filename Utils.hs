{- Copyright (c) 2005 John Goerzen
<jgoerzen@complete.org>
Please see the COPYRIGHT file
-}

module Utils where
import Darcs
import MissingH.Cmd
import MissingH.List

{- | Parse a tag into (type, package, version) -}
parseTag :: String -> Maybe (String, String, String)
parseTag inp =
    case split "_" inp of
       [t, pkg, ver] -> Just (t, pkg, ver)
       _ -> Nothing

upstreamTag :: String -> String -> String
upstreamTag pkg ver =
    "UPSTREAM_" ++ pkg ++ "_" ++ ver

{- | Given a list of tags, find the first one of the given type and package,
or Nothing if there are none yet. 

This should be the maximum version if this program has been used the entire
time. -}
getFirstVersion :: String -> String -> [String] -> Maybe String
getFirstVersion typ pkg tags =
    let taglist = filter 
                    (\(thist, thisp, thisv) -> thist == typ && thisp == pkg)
                    tags
        in case taglist of
             [] -> Nothing
             ((_,_,v):_) -> Just v

-- | Raise an error if we try to import something older than or the same
-- as the current maximum version in the system.
checkVersion typ pkg newver repodir =
    do (ph, tags) <- getTags repodir
       fv <- getFirstVersion typ pkg tags
       retval <- case fv of
           Nothing -> return ()
           Just v -> do c <- compareDebVersion fv newver
                        case c of 
                               LT -> return ()
                               _ -> fail $ "Existing version " ++ fv ++ 
                                      "is not less than new version " ++ newver
       seq (seqList tags) $ forceSuccess ph
       return retval

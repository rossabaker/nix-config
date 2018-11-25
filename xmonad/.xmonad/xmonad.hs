import XMonad
import XMonad.Actions.WorkspaceNames
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Layout.Decoration
import XMonad.Layout.NoBorders
import XMonad.Layout.NoFrillsDecoration
import XMonad.Layout.Renamed
import XMonad.Layout.Spacing
import XMonad.Prompt
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.Run

main = do
  xmproc <- spawnPipe "xmobar"
  xmonad $ ewmh def
    { manageHook = manageDocks <+> manageHook def
    , layoutHook = myLayout
    , logHook = workspaceNamesPP xmobarPP
                { ppCurrent = xmobarColor "white" "#00BCD4"
                , ppVisible = xmobarColor "white" ""
                , ppHidden = xmobarColor "white" ""
                , ppHiddenNoWindows = xmobarColor "gray50" ""
                , ppOutput = hPutStrLn xmproc
                , ppTitle = xmobarColor "white" "" . shorten 40
                } >>= dynamicLogWithPP
    , modMask = mod4Mask     -- Rebind Mod to the Windows key
    } `additionalKeys`
    [ ((mod4Mask, xK_b), sendMessage ToggleStruts)
    , ((mod4Mask, xK_o), rofi "window")
    , ((mod4Mask, xK_p), rofi "run")
    , ((mod4Mask, xK_r), renameWorkspace prompt)
    ]

myLayout = avoidStruts $ tall ||| wide ||| full
  where
    gap = (fromIntegral 6)
    tall = renamed [Replace "tall"] $
      addTopBar $
      noBorders $
      smartSpacingWithEdge gap $
      Tall 1 0.025 0.5
    wide = renamed [Replace "wide"] $
      addTopBar $
      noBorders $
      smartSpacingWithEdge gap $
      Mirror $
      Tall 1 0.025 0.5
    full = renamed [Replace "full"] $ noBorders $ Full
    addTopBar = noFrillsDeco shrinkText topBarTheme
    topBarTheme = def 
      { inactiveBorderColor   = "gray40"
      , inactiveColor         = "gray40"
      , inactiveTextColor     = "gray40"
      , activeBorderColor     = "#00BCD4"
      , activeColor           = "#00BCD4"
      , activeTextColor       = "#00BCD4"
      , urgentBorderColor     = "#FF5252"
      , urgentTextColor       = "#FF5252"
      , decoHeight            = 10
      }

rofi cmd = safeSpawn "rofi" [ "-show", cmd ]

prompt :: XPConfig
prompt = def
  { font = "xft:DejaVu Sans Mono:size=16"
  , height = 28
  , position = Top
  }